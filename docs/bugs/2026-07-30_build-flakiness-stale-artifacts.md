# Bug: Build flakiness — stale UTF-16 `.out` files prevent biber from running, producing zero-reference PDFs

**Date**: 2026-07-30
**Status**: Fixed
**Affects**: All `omega-pcf/*` repos with the shared build pipeline (`cleanup.ts` + `compile.ts`)
**Severity**: High — silent failure producing a structurally valid but academically broken PDF (no bibliography)
**Related**: [`2026-07-30_citation-js-duplicate-howpublished-url-overflow.md`](./2026-07-30_citation-js-duplicate-howpublished-url-overflow.md)

## 1. Observed behaviour

After fixing the `howpublished` duplication (separate bug doc, §5 above), `pnpm run build` would intermittently produce a PDF with **zero references** — the bibliography section was entirely absent. The build reported `✅ Build completed successfully` but the PDF had 20 pages instead of 21, and `pdftotext` extraction showed no `[N]` reference entries anywhere.

The LaTeX log (once `-quiet` was removed) revealed the actual error:

```
Runaway argument?
{\376\377\000T\000h\000e\000\040\000t\000a\000u\000t\000o\000l\000o\0\ETC.
! File ended while scanning use of \@@BOOKMARK.
<inserted text>
                \par
l.91 \begin{document}
```

The `\376\377` prefix is a **UTF-16 BOM** (`FF FE`). Hyperref writes its `.out` (PDF bookmarks) file in UTF-16 encoding. When a stale `.out` from a previous run survives into the next build, pdflatex fails while scanning it, aborts with return code 1, and latexmk never proceeds to the biber pass — so no `.bbl` is generated and the bibliography is empty.

## 2. Root cause

### 2.1 The cleanup was shallow, not recursive

`scripts/tasks/cleanup.ts` used `readdirSync(buildDir)` to scan only the top-level files in `build/`, then `unlinkSync` each matching stale extension. This missed:

1. **Files in subdirectories** — latexmk with `$out_dir = 'build'` and `-recorder` generates `.aux` files for `\input` chapters under `build/src/*.aux`, which the shallow scan never reached.
2. **Root-owned files** — Docker (`kjarosh/latex:2024.4-full`) runs as root, so all build artifacts are owned by `root:root`. While Node.js `rmSync({force:true})` can remove root-owned files when the parent directory is user-owned, the old `unlinkSync`-based approach was fragile.

### 2.2 The stale `.out` corruption chain

The failure chain was:

```
previous build → hyperref writes build/main.out (UTF-16)
                        │
                        ▼
next build starts → cleanup.ts scans build/ (shallow)
                        │
                        ▼
stale build/main.out survives (if cleanup misses it)
                        │
                        ▼
pdflatex run 1 → reads stale .out → "File ended while scanning \@@BOOKMARK"
                        │                → return code 1
                        ▼
latexmk aborts → never runs biber → no .bbl generated
                        │
                        ▼
pdflatex run 2 (if forced) → "Empty bibliography" → PDF with no references
```

### 2.3 The `-quiet` flag hid the error

`compile.ts` passed `-quiet` to latexmk, which suppressed the `! File ended` error output. The only signal was `pdflatex: Command for 'pdflatex' gave return code 1` and `Docker exit: 12` — with no indication of *what* file caused the failure.

## 3. Authoritative references consulted

Hound MCP searches on 2026-07-30:

- **texhax mailing list (Roger Price, Nov 2022)**: *"Package hyperref provokes Runaway argument. My error was to not remove the previous .out file before running pdflatex. Once I did this, the Runaway argument disappeared."* — [tug.org/pipermail/texhax/2022-November/025873.html](https://www.tug.org/pipermail/texhax/2022-November/025873.html)
- **TeX.SE: Runaway argument, File ended while scanning use of `\@newl@bel`**: *"If I delete the .aux file and recompile, everything is fine again."* — [tex.stackexchange.com/questions/299191](https://tex.stackexchange.com/questions/299191)
- **Reddit r/LaTeX: Runaway argument and .aux file error**: same conclusion — delete stale `.aux`/`.out`.
- **Batect docs: Stop build artefacts being owned by root**: *"On Linux, the Docker daemon runs as root... when a container writes a file to a mounted directory, it is owned by root."* — [batect.dev/docs/how-to/build-artefacts-owned-by-root](https://batect.dev/docs/how-to/build-artefacts-owned-by-root/)

## 4. Fix applied

### 4.1 `cleanup.ts` — recursive nuke

```ts
// Before (shallow — missed subdirectories and was fragile with root-owned files):
const files = readdirSync(buildDir);
const stale = files.filter(f => staleExtensions.some(ext => f.endsWith(ext)));
for (const f of stale) { try { unlinkSync(join(buildDir, f)); } catch {} }

// After (recursive — nukes everything):
rmSync(buildDir, { recursive: true, force: true });
mkdirSync(buildDir, { recursive: true });
```

The recursive `rmSync` eliminates all stale artifacts regardless of location or ownership, then recreates the empty directory. This is the correct approach because `build/` is entirely rebuildable — there is never a reason to preserve any file in it across builds.

### 4.2 `compile.ts` — remove `-quiet`, surface errors

```ts
// Before:
'latexmk', '-pdf', '-interaction=nonstopmode', '-quiet', sourceTex,
// ...
throw new Error(`PDF compilation failed - ${sourcePdf} not found.\nDocker exit: ${result.status}`);

// After:
'latexmk', '-pdf', '-interaction=nonstopmode', sourceTex,
// ...
printLogTail(`build/${baseName}.log`);  // dump last 80 lines of the log
throw new Error(`PDF compilation failed - ${sourcePdf} not found.\nDocker exit: ${result.status}`);
```

The `printLogTail()` function reads `build/main.log` on failure and prints its last 80 lines to stderr, so the actual TeX error is visible instead of a bare "not found" message.

## 5. Verification

After the fix, `pnpm run build` in all four repos produces:

- **04-mersenne-cr**: 21 pages (was 20), bibliography with 16 entries, GIMPS entry `[14]` renders with a single URL
- **01-hilbert-polya**: 69 pages, references present, no `howpublished` duplication
- **02-odd-zeta**: build successful, references present
- **03-crystalline-worldsheet**: build successful, references present

The build is now deterministic — no intermittent failures from stale artifacts.

## 6. Remaining notes

### 6.1 Docker root ownership

Docker still creates artifacts as `root:root`. The recursive `rmSync({force:true})` handles this because the parent `build/` directory is user-owned. A more principled fix would be `--user $(id -u):$(id -g)` in the Docker args, but this requires verifying that `TEXMFHOME=/dev/null` fully neutralizes the kpathsea host-contamination issue that motivated the original avoidance of `--user`. This is left as a future improvement; the current recursive cleanup is sufficient.

### 6.2 Cross-project propagation

The same three files (`citation.ts`, `cleanup.ts`, `compile.ts`) are shared across all four `omega-pcf` repos. The fix was applied to all four on 2026-07-30 with identical commit messages.
