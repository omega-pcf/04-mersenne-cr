# Docker biber/biblatex version mismatch — host TeX contamination

**Status**: Two bugs identified, both fixed  
**Date**: 2026-07-29  
**Severity**: Build-breaking  
**Investigation**: ~3 hours, Hound MCP for authoritative docs  
**Follow-up**: `DOCKER-BINDMOUNT-RACE-CONDITION.md` (Bug 3 — race condition revealed by these fixes)  

---

## Executive Summary

Two independent bugs broke the Docker-based LaTeX build:

1. **Host TeX contamination**: When Docker runs with `--user $(id -u):$(id -g)`,
   pdflatex somehow loads the host's biblatex 3.21 instead of Docker's 3.20,
   causing biber to reject the `.bcf` file.

2. **Shell line-continuation encoding**: The `DOCKER_TEX_ENV` array join used
   `\\\\\\n` (backslash + letter `n`) instead of `\\\n` (backslash + newline),
   breaking the Docker command into fragments. Biber received a truncated
   command and couldn't find `build/main.bcf`.

Both bugs were masked by each other: fixing one revealed the other.

---

## Environment

| Component       | Docker image (`kjarosh/latex:2024.4-full`) | Host (Ubuntu 26.04) |
|-----------------|-------------------------------------------|---------------------|
| OS              | Alpine Linux 3.20.3                       | Kubuntu 26.04       |
| TeX Live        | 2024                                      | 2024                |
| pdflatex        | 3.141592653-2.6-1.40.26                  | same                |
| biber           | **2.20**                                  | 2.20                |
| biblatex        | **3.20** (`/opt/texlive/texmf-dist/`)     | **3.21** (`/usr/share/texlive/texmf-dist/`) |

**Critical constraint** (verified via Hound MCP — Arch Linux, CTAN docs):
biber 2.20 is ONLY compatible with biblatex 3.20 exactly. Any other version
causes `bcf is malformed`.

---

## Bug 1: Host TeX contamination via `--user` flag

### Symptoms

```
ERROR - build/main.bcf is malformed, last biblatex run probably failed.
```

The `.bcf` file contains `bltxversion="3.21"` (host) instead of
`bltxversion="3.20"` (Docker).

### Evidence

| Test scenario | Result |
|---------------|--------|
| Docker terminal: `docker run ... pdflatex` | ✅ bltxversion=3.20 |
| Docker from `node -e` with execSync | ✅ bltxversion=3.20 |
| `pnpm run build` (full pipeline) | ❌ bltxversion=3.21 OR "Cannot find bcf" |

The `main.log` from the failing run shows:
```
(/usr/share/texlive/texmf-dist/tex/latex/biblatex/biblatex.sty
Package: biblatex 2025/07/10 v3.21
```

But inside Docker, `/usr/share/texlive` does NOT exist:
```bash
$ docker run --rm kjarosh/latex:2024.4-full ls /usr/share/texlive
ls: /usr/share/texlive: No such file or directory
```

Docker's biblatex is at `/opt/texlive/texmf-dist/tex/latex/biblatex/biblatex.sty`
(version 3.20). There is only ONE biblatex.sty in the entire container.

### Investigation steps

1. **Verified Docker image versions**: All kjarosh images (2024.4, 2024.5,
   2025.1) have biber 2.20 + biblatex 3.20. Upgrading doesn't help.

2. **Checked kpathsea configuration**: `kpsewhich` inside Docker correctly
   returns Docker's biblatex. But pdflatex loads the host's version.

3. **Checked TEXMF environment variables**: No TEXMF* vars set on host.
   No `.texmf` directory in user home.

4. **Checked Docker volume mount**: `-v $(pwd):$(pwd)` only exposes the
   project directory. Host's `/usr/share/texlive` is NOT mounted.

5. **Isolated `--user` as trigger**: Removing `--user $(id -u):$(id -g)`
   makes the build succeed consistently. This is the key finding.

### kpathsea behavior (from TUG authoritative docs via Hound MCP)

- kpathsea reads ALL `texmf.cnf` files in the search path
- `TEXMFHOME = ~/texmf` (default), resolved via `HOME` env var
- When `--user $(id -u):$(id -g)` is used, `HOME=/` (UID has no passwd entry)
- So `TEXMFHOME = /.texmf` which doesn't exist — should be safe
- Environment variables override texmf.cnf values

### Unresolved mystery

**How does the host's biblatex 3.21 reach pdflatex inside Docker when
`--user` is used?**

Verified facts:
- `/usr/share/texlive` does NOT exist inside Docker
- `kpsewhich` correctly finds Docker's biblatex
- The contamination only happens via `pnpm run build`, not direct Docker
- The `--user` flag is the trigger

Theories (not confirmed):
1. Docker `--user` changes process capabilities that affect kpathsea's
   SELFAUTOPARENT resolution
2. Some Docker/overlay2 caching mechanism preserves host path lookups
3. Node.js `execSync` via pnpm sets something different than terminal shell

### Fix

Remove `--user` from Docker commands. Running as root inside Docker is safe
for build-only containers. Files on the volume mount retain host ownership.

---

## Bug 2: Shell line-continuation encoding in `DOCKER_TEX_ENV`

### Symptoms

```
ERROR - Cannot find 'build/main.bcf'!
```

pdflatex ran and produced `Output written on build/main.pdf`, but biber
couldn't find the `.bcf` file that pdflatex should have created.

### Root cause

The `DOCKER_TEX_ENV` array join used:

```typescript
].join(' \\\\\\n    ');
```

In JavaScript, this produces the string ` \\` + letter `n` + `    `. In
hex: `5c 5c 6e 20 20 20 20`.

The shell sees `\\` (escaped backslash = literal `\`) followed by `n` (letter),
NOT `\` followed by newline. This is NOT line continuation — it's a literal
backslash followed by the letter `n`, which the shell treats as part of the
command arguments.

### What happened

The Docker command for biber was fragmented:

```
docker run --rm \
    -v $(pwd):$(pwd) \
    ...
    -e TEXMFDIST=/opt/texlive/texmf-dist \\     ← not line continuation!
n    -e TEXMFHOME=/dev/null \\                    ← starts with 'n'!
n    ...
```

The `\\` + `n` broke the command. Docker received a truncated command,
pdflatex output was lost, and biber couldn't find `build/main.bcf`.

### The encoding trap

This is a classic multi-encoding trap:

| Layer | What you write | What you get |
|-------|---------------|--------------|
| JS source | `\\\\\\n` | `\` `\` `\n` (two backslashes + newline) |
| JS runtime | The join produces | `\\n` as a string (two chars) |
| Shell exec | Shell sees | `\\` (escaped backslash) + `n` (literal) |

The correct JS source should be `\\\n` (one backslash + newline in the
string), which the shell interprets as line continuation.

### Verification

```bash
# Before fix (hex of line 19):
$ xxd scripts/tasks/compile.ts | grep "join"
5c5c6e = \ \ n (backslash backslash letter-n)

# After fix:
5c0a   = \ newline (backslash + actual newline)
```

### Fix

Used Python byte-level replacement to write the correct bytes (`5c 0a`)
directly, bypassing all shell/JS escaping layers.

---

## Fixes Applied to `compile.ts`

### 1. Remove `--user` flag

```typescript
// Before: --user $(id -u):$(id -g) \
// After:  (removed — runs as root inside Docker)
```

### 2. Explicit TeX environment isolation

```typescript
const DOCKER_TEX_ENV = [
  '-e TEXMFDIST=/opt/texlive/texmf-dist',
  '-e TEXMFHOME=/dev/null',
  '-e TEXMFLOCAL=/opt/texlive/texmf-local',
  '-e TEXMFSYSCONFIG=/opt/texlive/texmf-config',
  '-e TEXMFSYSVAR=/opt/texlive/texmf-var',
].join(' \\\n    ');  // ← single backslash + newline
```

### 3. Pre-biber version check

Reads `bltxversion` from `.bcf` before invoking biber. Throws clear error
if version doesn't match 3.20.

---

## Lessons Learned

1. **Docker `--user` + kpathsea is dangerous**: The `--user` flag changes
   process identity in ways that can affect kpathsea's path resolution,
   even when all environment variables are explicitly set.

2. **Multi-encoding traps in build scripts**: JavaScript template literals,
   shell escaping, and Docker argument parsing create a triple-encoding
   layer where a single character mistake (extra backslash) can break
   everything silently.

3. **Intermittent bugs need structured debugging**: The bug manifested
   differently depending on invocation method (terminal vs node vs pnpm).
   Only systematic isolation (removing one variable at a time) revealed
   the two independent causes.

4. **Validate Docker commands outside the pipeline first**: Running Docker
   commands directly from terminal helped isolate whether the issue was
   in the Docker configuration or in the build pipeline.

5. **Hex inspection is essential for encoding bugs**: `cat -A`, `xxd`, and
   Python byte inspection were necessary to confirm the actual bytes in
   the file versus what the source code appeared to say.

---

## References

- [CTAN biber/biblatex compatibility matrix](https://ctan.org/pkg/biber)
- [kpathsea documentation](https://tug.org/texinfohtml/kpathsea.html)
- [Arch Linux: biber 2.20 works with biblatex 3.20 only](https://bbs.archlinux.org/viewtopic.php?id=304879)
- [kjarosh/latex-docker](https://github.com/kjarosh/latex-docker)
- [pnpm exec documentation](https://pnpm.io/cli/exec)
- [Docker bind mount docs](https://docs.docker.com/engine/storage/bind-mounts/)

---

*Documented by Hermes Agent during investigation session 2026-07-29.*
