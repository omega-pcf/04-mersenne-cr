#!/usr/bin/env bash
# Build all standalone figure PDFs from scripts/figures/*.tex → images/*.pdf
set -euo pipefail

FIGDIR="scripts/figures"
OUTDIR="images"
DOCKER_IMAGE="kjarosh/latex:2024.4-full"

mkdir -p "$OUTDIR"

for texfile in "$FIGDIR"/*.tex; do
  [ -f "$texfile" ] || continue
  base="$(basename "$texfile" .tex)"
  echo "  📊 Generating $base.pdf ..."
  docker run --rm \
    --user "$(id -u):$(id -g)" \
    -v "$(pwd):$(pwd)" \
    -w "$(pwd)" \
    "$DOCKER_IMAGE" \
    sh -c "pdflatex -interaction=nonstopmode -output-directory=$OUTDIR $texfile && mv $OUTDIR/$base.pdf $OUTDIR/$base.pdf" \
    > /dev/null 2>&1
  # Clean aux files from images/
  rm -f "$OUTDIR/$base".{aux,log,out}
done

echo "✅ Figures generated in $OUTDIR/"
