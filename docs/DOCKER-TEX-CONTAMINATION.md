# Docker LaTeX build — bugs found and investigation log

**Status**: Bug 1 and Bug 2 fixed. Bug 3 (race condition) and Bug 4 (stdio interaction) still under investigation.  
**Date**: 2026-07-29  
**Severity**: Build-breaking (intermittent)  

---

## Bugs fixed

### Bug 1: Host TeX contamination via `--user` flag

**Symptom**: `bcf is malformed` — biber rejects `.bcf` because it contains `bltxversion="3.21"` (host) instead of `"3.20"` (Docker).

**Root cause**: `--user $(id -u):$(id -g)` in the Docker command changes kpathsea's path resolution, causing pdflatex to load the host's biblatex 3.21 instead of Docker's 3.20. biber 2.20 is ONLY compatible with biblatex 3.20 exactly.

**Fix applied**: Remove `--user` from Docker commands. Running as root inside Docker is safe for build-only containers.

**Status**: ✅ Fixed in `compile.ts`

### Bug 2: Shell line-continuation encoding in `DOCKER_TEX_ENV`

**Symptom**: `Cannot find 'build/main.bcf'!` — biber receives a truncated command.

**Root cause**: The `DOCKER_TEX_ENV` array join used `\\\\n` (backslash + letter `n`) instead of `\\\n` (backslash + newline). Hex verification confirmed: bytes were `5c 5c 6e` instead of `5c 0a`.

**Fix applied**: Corrected the join to produce actual backslash + newline bytes.

**Status**: ✅ Fixed in `compile.ts`

---

## Bugs still under investigation

### Bug 3: Bind-mount filesystem race condition

**Symptom**: `Cannot find 'build/main.bcf'!` — identical to Bug 2 but caused by a different mechanism.

**Root cause**: The original `compile.ts` spawns 4 separate `docker run --rm` containers in sequence. When Docker destroys a container with `--rm`, the kernel may not flush all pending writes to the bind mount before the next `docker run` starts. Evidence: `main.synctex(busy)` file present (0 bytes) proves the container was destroyed before pdflatex finished cleanup I/O.

**What we tried**:
- Single-container pipeline (`sh -c "set -e; pdflatex; biber; pdflatex; pdflatex; sync"`) — works from terminal and `node -e`, but fails via `pnpm run build` with `execSync({ stdio: 'inherit' })`. Files appear inside Docker but vanish from host.
- Separate containers with `spawnSync({ stdio: 'pipe' })` — biber still can't find `.bcf` (race condition persists between containers).

**What we know**:
- Single container works from terminal: ✅
- Single container works from `node -e`: ✅
- Single container fails from `pnpm run build` via `execSync({ stdio: 'inherit' })`: ❌
- The exact same command string works or fails depending on invocation context

**Status**: ⚠️ Unresolved. The race condition between separate containers is real. The single-container fix is blocked by an interaction between `execSync` stdio passthrough and Docker bind mounts.

### Bug 4: `execSync` stdio passthrough breaks Docker bind mounts

**Symptom**: pdflatex inside Docker reports "Output written on build/main.pdf" but the file doesn't exist on the host. Files appear inside Docker's view but vanish ~1s after container exit. `.synctex(busy)` present (0 bytes).

**Root cause**: When `execSync(dockerCmd, { stdio: 'inherit' })` is used, Docker's output goes directly to the terminal via Node.js's stdio passthrough. Something about this interaction prevents bind-mount writes from being flushed to the host.

**Confirmed by A/B testing**: Identical Docker command succeeds with `stdio: 'pipe'` but fails with `stdio: 'inherit'`. No FD leaks, no env var changes, no inotify watchers detected.

**What we know**:
- `spawnSync({ stdio: 'pipe' })` works: ✅
- `execSync({ stdio: 'inherit' })` fails: ❌
- The issue is specific to when `citation.ts` imports are loaded before Docker runs
- Loading the same imports without calling `syncCitationMetadata()` does NOT trigger the bug
- Calling `syncCitationMetadata()` triggers the bug even when the same operations are replicated manually with dynamic imports

**Status**: ⚠️ Unresolved. Root cause narrowed but not identified. The interaction between Node.js module loading context and Docker's bind-mount behavior is not well documented.

---

## Environment

| Component | Docker image (`kjarosh/latex:2024.4-full`) | Host (Ubuntu 26.04) |
|-----------|-------------------------------------------|---------------------|
| OS | Alpine Linux 3.20.3 | Kubuntu 26.04 |
| TeX Live | 2024 | 2024 |
| pdflatex | 3.141592653-2.6-1.40.26 | same |
| biber | **2.20** | 2.20 |
| biblatex | **3.20** (`/opt/texlive/texmf-dist/`) | **3.21** (`/usr/share/texlive/texmf-dist/`) |

**Critical constraint**: biber 2.20 is ONLY compatible with biblatex 3.20 exactly. Any other version causes `bcf is malformed`.

---

## References

- [CTAN biber/biblatex compatibility matrix](https://ctan.org/pkg/biber)
- [SyncTeX stays busy — texstudio-org/texstudio#3655](https://github.com/texstudio-org/texstudio/issues/3655)
- [kpathsea documentation — TUG](https://tug.org/texinfohtml/kpathsea.html)
- [Docker bind mount propagation — Stack Overflow](https://stackoverflow.com/questions/53547973)
- [kjarosh/latex-docker](https://github.com/kjarosh/latex-docker)
- [Files disappear in volume mounts — moby/moby#41750](https://github.com/moby/moby/issues/41750)

---

## File changes in this investigation

| File | Change |
|------|--------|
| `scripts/tasks/compile.ts` | Removed `--user`, fixed DOCKER_TEX_ENV encoding, added TEXMF isolation, added biber version check |
| `docs/DOCKER-TEX-CONTAMINATION.md` | This document |

---

*Documented by Hermes Agent during investigation session 2026-07-29.*
*Honesty note: Bug 3 and Bug 4 remain unresolved. Previous claims of "fix applied" were premature.*
