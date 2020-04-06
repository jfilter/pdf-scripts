#!/usr/bin/env bash
set -e
set -x

# still WIP

do_ocr () {
  fn=$(basename -- "$1")
  echo $fn
  docker run --rm -v "$(pwd):/data" jbarlow83/ocrmypdf -l deu --pdf-renderer hocr --deskew --output-type pdf --clean --force-ocr --optimize 1 /data/$fn /data/$fn.out.pdf && mv $1.out.pdf $2/$fn
}

mkdir -p $PWD/out

if [[ -d $PWD/$1 ]]; then
  # directory of PDFs, need to create tmp file to store all args
  for f in $PWD/$1/*.pdf; do do_ocr $f $PWD/out; done
elif [[ -f $PWD/$1 ]]; then
  # single pdf
  do_ocr $PWD/$1 $PWD/out
else
  echo "error: please provide some valid input file(s)"
  exit 1
fi
