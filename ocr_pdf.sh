#!/usr/bin/env bash
set -e
set -x

################################################################################
# Simple wrapper around OCRmyPDFs Docker image to OCR PDFs with Tesseract
#
# Usage:
#   bash ocr_pdf.sh [-l] [-o] [-f] [-a] input.pdf
#
# Arguments:
#   -l or --level: level of compression (1-5), the higher the harder
#                  the compression. Defaults to 4.
#
# not all languages are supported with the Docker image
# https://ocrmypdf.readthedocs.io/en/latest/docker.html#adding-languages-to-the-docker-image
# https://github.com/tesseract-ocr/tesseract/blob/master/doc/tesseract.1.asc#languages
# eng - English, deu - German, spa - Spanish, fra - French, por - Portuguese, chi_sim - Chinese simplified
#
# Please report issues at https://github.com/jfilter/pdf-scripts/issues
#
# GPLv3, Copyright (c) 2020 Johannes Filter
################################################################################

# parse arguments
# h/t https://stackoverflow.com/a/33826763/4028896
# skip over positional argument of the file(s), thus -gt 1

lang="eng" && optimize=1 && force_ocr=0 && clean=0 && args=""

while [[ "$#" -gt 1 ]]; do
  case $1 in
  -l | --language)
    lang="$2"
    shift
    ;;
  -o | --optimize)
    optimize="$2"
    shift
    ;;
  -f | --force)
    force_ocr="$2"
    shift
    ;;
  -a | --args)
    args="$2"
    shift
    ;;
  -c | --clean) clean=1 ;;
  *)
    echo "Unknown parameter passed: $1"
    exit 1
    ;;
  esac
  shift
done

# $1 file input, modify inplace
# in $6 are the remaining args
do_ocr() {
  # macOS command is different
  if [ "$(uname)" == "Darwin" ]; then
    tmpdir=$(mktemp -d /tmp/foo.XXXXXXXXXX)
  else
    tmpdir=$(mktemp -d)
  fi
  cp $1 $tmpdir/
  fn=$(basename -- "$1")
  echo $fn

  if (($3 == 0)); then
    force_txt="--skip-text --deskew"
  elif (($3 == 1)); then
    force_txt="--redo-ocr"
  elif (($3 == 2)); then
    force_txt="--force-ocr --deskew"
  else
    echo "wrong input for --force"
    exit 1
  fi

  clean_txt=""
  if (($4 == 1)); then
    clean_txt="--remove-background --clean-final"
  fi

  opt="$2"
  if ((opt == 3)); then
    opt="3 --jbig2-lossy"
  fi

  docker run --rm -v "$tmpdir:/data" jbarlow83/ocrmypdf -l $5 --pdf-renderer hocr --output-type pdf --clean $force_txt $clean_txt $6 --optimize $opt /data/$fn /data/$fn.out.pdf && mv -f $tmpdir/$fn.out.pdf $1
}

if [[ $1 == /* ]]; then
  input=$1
else
  input=$PWD/$1
fi

if [[ -d $input ]]; then
  # directory of PDFs, need to create tmp file to store all args
  for f in "$input"/*.pdf; do
    do_ocr "$f" "$optimize" "$force_ocr" "$clean" "$lang" "$args"
  done
elif [[ -f $input ]]; then
  # single pdf
  do_ocr "$input" "$optimize" "$force_ocr" "$clean" "$lang" "$args"
else
  echo "error: please provide some valid input file(s)"
  exit 1
fi
