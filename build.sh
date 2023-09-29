#!/bin/bash

USER_DIR=$(readlink -f "$1")
WORKDIR=$(mktemp -d -p "$USER_DIR")

cd "$WORKDIR" || exit 1

# Build PDFs from LaTeX. Do the build twice to sort out any bookmarks.
find "$USER_DIR" -type f -name '*.tex' -print0 | while IFS= read -r -d '' file; do
  echo ">>> $file"
  ls -la "$file"
  output=$(dirname "$file")/$(basename "$file" .tex).pdf
  if [ -f "$output" ]; then
      echo "Skipping $file as already built"
      exit 0
  fi
  echo "$file - $output"
  HOME=$(pwd) SOURCE_DATE_EPOCH=1622905527 pdflatex "$file" || exit 1
  HOME=$(pwd) SOURCE_DATE_EPOCH=1622905527 pdflatex "$file" || exit 1
  mv "$(basename "$output")" "$output" || exit 1
done

cd "$USER_DIR" || exit 1
rm -r "$WORKDIR"
