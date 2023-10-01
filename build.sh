#!/bin/bash

USER_DIR=$(readlink -f "$1")

mkdir "output"

# Build PDFs from LaTeX.
find "$USER_DIR" -type f -name '*.tex' -print0 | while IFS= read -r -d '' file; do
  output=$(readlink -f "$(dirname "$file")/$(basename "$file" .tex).pdf")
  if [ -f "$output" ]; then
      echo "Skipping $file as already built"
  else
      file=$(readlink -f "$file")
      echo "$file - $output"
      pushd "$(dirname "$output")" || exit 1
      # Do the build twice to sort out any bookmarks.
      HOME=$(pwd) SOURCE_DATE_EPOCH=1622905527 pdflatex "$file" || exit 1
      HOME=$(pwd) SOURCE_DATE_EPOCH=1622905527 pdflatex "$file" || exit 1
      popd || exit 1
  fi
done

cd "$USER_DIR" || exit 1
