#!/usr/bin/env bash
# Build all standalone figure PDFs from scripts/figures/*.tex → images/*.pdf
set -euo pipefail

FIGDIR="scripts/figures"
OUTDIR="images"
DOCKER_IMAGE="kjarosh/latex:2024.4-full"
# Deterministic PDFs: pdfTeX writes the wall clock into /CreationDate (and
# /ModDate) unless SOURCE_DATE_EPOCH is set, so two runs of this script used
# to produce different bytes and leave `git status images/` dirty.  Pinned to
# the timestamp of the figure round that produced images/ (2026-11-09
# 19:31:03 -06:00); an explicitly exported value still wins.  Fonts are
# TeX Live's own Type 1 math fonts, which already carry /ToUnicode.
# See docs/figures.md.
SOURCE_DATE_EPOCH="${SOURCE_DATE_EPOCH:-1794274263}"

mkdir -p "$OUTDIR"

for texfile in "$FIGDIR"/*.tex; do
  [ -f "$texfile" ] || continue
  base="$(basename "$texfile" .tex)"
  echo "  📊 Generating $base.pdf ..."
  docker run --rm \
    --user "$(id -u):$(id -g)" \
    -e "SOURCE_DATE_EPOCH=$SOURCE_DATE_EPOCH" \
    -v "$(pwd):$(pwd)" \
    -w "$(pwd)" \
    "$DOCKER_IMAGE" \
    sh -c "pdflatex -interaction=nonstopmode -output-directory=$OUTDIR $texfile && mv $OUTDIR/$base.pdf $OUTDIR/$base.pdf" \
    > /dev/null 2>&1
  # Clean aux files from images/
  rm -f "$OUTDIR/$base".{aux,log,out}
done

echo "✅ Figures generated in $OUTDIR/"
