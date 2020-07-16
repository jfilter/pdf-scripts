#!/usr/bin/env bash
set -e
set -x

# Checks a flat folder of PDFs and sorts them into analog (scanned & OCR)
# and digital PDFs

dir_path=$(dirname $0)

sort_pdf() {
  $2/../is_ocrd_pdf.sh -p 2 $1
  exit_code=$?
  if ((exit_code == 99)); then
    cp $1 $3/../digital
  else
    if ((exit_code == 0)); then
      cp $1 $3/../analog
    else
      exit 1
    fi
  fi
}

if [[ $1 == /* ]]; then
  input=$1
else
  input=$PWD/$1
fi

mkdir -p $input/../digital
mkdir -p $input/../analog

export -f sort_pdf &&
  ALL_PDFS=$(mktemp) &&
  for f in $input/*.pdf; do echo $f >>$ALL_PDFS; done &&
  parallel --bar sort_pdf :::: "${ALL_PDFS}" ::: $dir_path ::: $input
