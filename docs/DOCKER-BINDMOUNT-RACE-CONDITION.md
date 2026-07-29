# Docker bind-mount filesystem race condition

**Status**: Investigation in progress — partial fix applied, root cause narrowing ongoing  
**Date**: 2026-07-29  
**Severity**: Build-breaking (intermittent, ~60–80% failure rate)  
**Investigation**: ~4 hours, Hound MCP consulted for authoritative docs  
**Prerequisite**: `docs/DOCKER-TEX-CONTAMINATION.md` (Bugs 1 & 2)  

---

## Executive summary

The two bugs documented in `DOCKER-TEX-CONTAMINATION.md` (host TeX
contamination via `--user`, and shell line-continuation encoding) were
**necessary but insufficient fixes**. A third, deeper bug causes the
same symptoms (`Cannot find 'build/main.bcf'` and `bcf is malformed`)
through a fundamentally different mechanism: **filesystem race
conditions on Docker bind mounts during container teardown**.

### The three bugs (corrected understanding)

| Bug | Mechanism | Status |
|-----|-----------|--------|
| **Bug 1**: Host TeX contamination | `--user` flag changes kpathsea resolution, host biblatex 3.21 leaks in | ✅ Fixed (remove `--user`) |
| **Bug 2**: Line-continuation encoding | `\\\\n` in JS produces literal backslash + letter `n`, not line continuation | ✅ Fixed (`5c 0a` bytes confirmed) |
| **Bug 3**: Bind-mount write race | Docker `--rm` destroys container before kernel flushes writes to host | ⚠️ Partially fixed (see Current fix) |

Bugs 1 and 2 masked Bug 3. Fixing them revealed the race condition,
which manifests identically to the original symptoms.

---

## Bug 3: Root cause analysis

### Symptoms (identical to Bugs 1 & 2)

```
ERROR - Cannot find 'build/main.bcf'!
INFO - ERRORS: 1
```

OR (intermittently):

```
ERROR - build/main.bcf is malformed, last biblatex run probably failed.
```

### Mechanism

The original `compile.ts` spawned **4 separate `docker run --rm`
containers** in sequence:

1. `docker run --rm ... pdflatex`  (pass 1 — generates `.bcf`)
2. `docker run --rm ... biber`     (pass 2 — reads `.bcf`, writes `.bbl`)
3. `docker run --rm ... pdflatex`  (pass 3 — incorporates bibliography)
4. `docker run --rm ... pdflatex`  (pass 4 — resolves cross-refs)

When Docker destroys a container with `--rm`, the kernel's page cache
may not have finished flushing all writes to the bind-mounted host
directory. The next `docker run` starts immediately and sees a
**partial or empty** `build/` directory.

### Evidence

**5-run reproducibility test** (original 4-container design):

| Run | Files in `build/` after pdflatex pass 1 | `.bcf` |
|-----|------------------------------------------|--------|
| #1  | 7 files — `main.synctex(busy)` present, no `.bcf` | ❌ MISSING |
| #2  | Same as #1 | ❌ MISSING |
| #3  | Same as #1 | ❌ MISSING |
| #4  | Same as #1 | ❌ MISSING |
| #5  | 10 files — all correct including `.bcf` | ✅ EXISTS |

4 out of 5 runs produced an incomplete `build/` directory despite
pdflatex reporting `Output written on build/main.pdf`.

### The `synctex(busy)` smoking gun

The key diagnostic signal was `main.synctex(busy)` — a temporary file
that SyncTeX creates during compilation and atomically renames to
`main.synctex.gz` on clean exit. Its presence in `build/` proves the
container was destroyed **before pdflatex finished its cleanup I/O**.

SyncTeX behavior confirmed via Hound MCP (GitHub texstudio-org/texstudio
issue #3655): *"SyncTeX: Can't rename file.synctex(busy) to
file.synctex.gz"* is a known race when the process is interrupted
prematurely.

### Why Bugs 1 & 2 masked Bug 3

- **Bug 1** (host contamination) was the dominant failure mode. Its
  `--user`-dependent nature made the bug appear deterministic, hiding
  the stochastic race underneath.
- **Bug 2** (encoding) either broke the command entirely or didn't,
  producing a binary pass/fail that obscured the probabilistic race.
- Only after fixing both did the intermittent pattern become visible:
  sometimes the build works, sometimes it doesn't, with no code change.

---

## Current fix applied to `compile.ts`

### 1. Single-container pipeline

All 4 LaTeX passes now run inside **one** Docker container via
`sh -c "set -e; pdflatex ...; biber ...; pdflatex ...; pdflatex ...; sync"`.

This eliminates inter-container filesystem races: all writes happen
within the same container's lifecycle, and `sync` forces a kernel
flush before the container exits.

### 2. SyncTeX disabled

`-synctex=0` prevents creation of the `.synctex(busy)` temporary file.
SyncTeX data is unnecessary for reproducible release builds.

### 3. TeX environment isolation (from Bug 1 fix)

Explicit `TEXMFDIST`, `TEXMFHOME=/dev/null`, `TEXMFLOCAL`,
`TEXMFSYSCONFIG`, `TEXMFSYSVAR` environment variables force Docker's
own TeX installation, preventing host contamination.

### 4. Biber version safety check

Reads `bltxversion` from `.bcf` before accepting the build. Throws a
clear error if host contamination is detected.

### Reliability results

| Test | Environment | Result |
|------|-------------|--------|
| Manual `docker run` (single container) | Terminal shell | 5/5 success |
| `pnpm exec tsx -e` (inline script) | Node.js + tsx | 5/5 success |
| `pnpm run build` (full pipeline) | Node.js + tsx + citation.ts | 2/5 success |

**The single-container fix is reliable in isolation but the full
`build.ts` pipeline still fails ~60% of the time.** See Unresolved.

---

## Unresolved: `build.ts`-specific failure

### Observation

The exact same Docker command string succeeds 100% when executed via
`pnpm exec tsx -e '...'` (inline script) but fails ~60% when executed
via `pnpm exec tsx scripts/build.ts` (file).

### What differs

`build.ts` runs `syncCitationMetadata()` from `citation.ts` **before**
`compilePDF()`. The `citation.ts` module imports heavy dependencies:
`ajv`, `@citation-js/core` (with 5 plugins), `yaml`, `escape-latex`,
`unicode2latex`. These may affect the Node.js process environment in
ways that influence `execSync` behavior with `stdio: 'inherit'`.

### Tested hypotheses

| Hypothesis | Test | Result |
|------------|------|--------|
| TEXMF env vars leak from host | `process.env` inspection | ❌ No TEX vars present |
| `HOME` points to host texmf | `echo $HOME` inside docker | `HOME=/home/aficio` but no `~/texmf` exists |
| `stdio: 'pipe'` vs `'inherit'` | Both modes tested in isolation | Both work in `tsx -e`; issue is `build.ts`-specific |
| Race on bind mount (original) | Single container with `sync` | Fixes manual/tsx-e but not `build.ts` |

### Next steps

1. **Test `stdio: 'pipe'` in `compile.ts`** — capture stdout/stderr
   in a buffer and log it, instead of inheriting the parent's stdio.
   This eliminates any terminal/pipe interaction issues.

2. **Write Docker commands to a temp `.sh` script** — execute the
   script via `bash /tmp/build-latex.sh` instead of building the
   command string inline in TypeScript. Eliminates all escaping and
   template-literal interaction issues.

3. **Investigate `execSync` maxBuffer** — with `stdio: 'inherit'`,
   Node.js may hit a buffer limit when pdflatex produces very large
   output (the `.pfb` font listing is ~50KB). Test with
   `maxBuffer: 10 * 1024 * 1024`.

4. **Switch to `spawnSync` with pipe** — `execSync` is a wrapper
   around `spawnSync` that buffers all output. `spawnSync` with
   explicit `{ stdio: 'pipe' }` gives finer control over buffer
   sizes and error handling.

5. **Profile memory/CPU around `citation.ts`** — the heavy imports
   may cause GC pressure or file-handle exhaustion that affects
   subsequent `execSync` calls.

---

## Hound MCP references consulted

- [CTAN biber/biblatex compatibility matrix](https://ctan.org/pkg/biber)
- [SyncTeX stays busy — texstudio-org/texstudio#3655](https://github.com/texstudio-org/texstudio/issues/3655)
- [kpathsea documentation — TUG](https://tug.org/texinfohtml/kpathsea.html)
- [biber `--include-directory` — plk/biber#32](https://github.com/plk/biber/issues/32)
- [Docker bind mount propagation — Stack Overflow](https://stackoverflow.com/questions/53547973)
- [kjarosh/latex-docker](https://github.com/kjarosh/latex-docker)

---

## File changes in this investigation

| File | Change |
|------|--------|
| `scripts/tasks/compile.ts` | Single-container pipeline, `-synctex=0`, TEXMF isolation, `sync`, biber version check |
| `docs/DOCKER-BINDMOUNT-RACE-CONDITION.md` | This document (new) |

---

*Documented by Hermes Agent during investigation session 2026-07-29.*
