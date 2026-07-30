# Docker LaTeX build — bugs found and investigation log

**Status**: All bugs fixed. Using `latexmk` (industry standard) instead of manual pdflatex/biber.  
**Date**: 2026-07-29  
**Severity**: Resolved  

---

## Bugs found and fixed

### Bug 1: Host TeX contamination via `--user` flag

**Symptom**: `bcf is malformed` — biber rejects `.bcf` because it contains `bltxversion="3.21"` (host) instead of `"3.20"` (Docker).

**Root cause**: `--user $(id -u):$(id -g)` in the Docker command changes kpathsea's path resolution, causing pdflatex to load the host's biblatex 3.21 instead of Docker's 3.20. biber 2.20 is ONLY compatible with biblatex 3.20 exactly.

**Fix**: Remove `--user` from Docker commands. Running as root inside Docker is safe for build-only containers.

### Bug 2: Shell line-continuation encoding in `DOCKER_TEX_ENV`

**Symptom**: `Cannot find 'build/main.bcf'!` — biber receives a truncated command.

**Root cause**: The `DOCKER_TEX_ENV` array join used `\\\\n` (backslash + letter `n`) instead of `\\\n` (backslash + newline). Hex verification confirmed: bytes were `5c 5c 6e` instead of `5c 0a`.

**Fix**: Corrected the join to produce actual backslash + newline bytes.

### Bug 3: Manual pdflatex/biber invocation — use `latexmk` instead

**Symptom**: Intermittent failures with separate `docker run` containers. Files don't persist between containers (bind-mount race condition). Single-container approach with `sh -c "..."` failed via `pnpm run build` due to shell escaping and stdio interaction issues.

**Root cause**: Manually orchestrating pdflatex → biber → pdflatex → pdflatex across Docker containers is fragile. Each container lifecycle introduces race conditions on bind mounts. Shell command strings built in TypeScript have multi-encoding traps.

**Fix**: Use `latexmk` — the industry standard for LaTeX compilation. `latexmk` handles the full pdflatex → biber → pdflatex → pdflatex pipeline internally, in a single Docker container, with a single command. This eliminates all race conditions, shell escaping issues, and stdio interaction bugs.

**Evidence**: `xu-cheng/latex-action` (most popular LaTeX GitHub Action), `Amet13/tex-thesis`, and `mingchen/docker-latex` all use `latexmk` for Docker-based compilation.

**Configuration**: `.latexmkrc` already configured with `$out_dir = 'build'`, correct `$pdflatex` and `$biber` commands.

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
- [xu-cheng/latex-action](https://github.com/xu-cheng/latex-action) — most popular Docker LaTeX GitHub Action, uses `latexmk`
- [Amet13/tex-thesis](https://github.com/Amet13/tex-thesis) — uses `latexmk` in Docker via Makefile
- [mingchen/docker-latex](https://github.com/mingchen/docker-latex) — Docker LaTeX wrapper
- [kpathsea documentation — TUG](https://tug.org/texinfohtml/kpathsea.html)
- [kjarosh/latex-docker](https://github.com/kjarosh/latex-docker)

---

## File changes

| File | Change |
|------|--------|
| `scripts/tasks/compile.ts` | Use `latexmk` via `spawnSync` args array, remove `--user`, add TEXMF isolation, biber version check |
| `.latexmkrc` | Pre-existing, correctly configured |
| `docs/DOCKER-TEX-CONTAMINATION.md` | This document |

---

*Documented by Hermes Agent. Investigation session 2026-07-29.*
