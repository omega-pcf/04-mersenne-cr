# Figure pipeline: deterministic PDFs

`pnpm run generate:figures` runs `scripts/figures/build.sh`, which compiles
every `scripts/figures/*.tex` with **pdflatex inside the
`kjarosh/latex:2024.4-full` Docker image** and writes the PDF into `images/`.
This is the one figure pipeline of the family that does not use matplotlib.

## What it guarantees

1. **The text in the PDF is extractable.** TeX Live's Type 1 math fonts
   (`cmmi10`, `cmsy10`, …) carry `/ToUnicode`, so `pdftotext` reads `θ`, `π`,
   `ζ₁₀`, `φ` back — no font work needed here.
2. **Two consecutive runs are byte-identical.** pdfTeX writes the wall clock
   into `/CreationDate` and `/ModDate` unless `SOURCE_DATE_EPOCH` is set;
   `build.sh` passes it into the container, so `git status --porcelain
   images/` does not change between runs.

## Setting

| Setting | Value | Where | Reason |
| --- | --- | --- | --- |
| `SOURCE_DATE_EPOCH` | `1794274263` | `scripts/figures/build.sh` (`docker run -e`) | The timestamp of the figure round that produced `images/` (2026-11-09 19:31:03 -06:00). An explicitly exported value still wins. |

Environment variables are not inherited by `docker run` unless passed with
`-e`, which is why the pin lives there and not only in the shell.

## Verifying

```bash
pnpm run generate:figures          # run once
sha256sum images/* > /tmp/a
pnpm run generate:figures          # run twice
sha256sum images/* > /tmp/b && diff /tmp/a /tmp/b   # must be silent

pdffonts images/cd_correspondance.pdf    # emb sub uni: yes yes yes
pdftotext images/cd_correspondance.pdf - # reads θ, π, ζ₁₀ …
```

The Docker image is required (`docker pull kjarosh/latex:2024.4-full`); no
host font or matplotlib is involved.
