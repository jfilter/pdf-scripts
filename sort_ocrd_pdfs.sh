#!/usr/bin/env bash
set -e
set -x

# still WIP, assumes 'analog' PDFs were already OCRd

dir_path=$(dirname $0)

mkdir -p $PWD/digital
mkdir -p $PWD/analog

sort_pdf() {
  $2/is_ocrd_pdf.sh -p 2 $1
  exit_code=$?
  if ((exit_code == 99)); then
    cp $1 $PWD/digital
  else
    if ((exit_code == 0)); then
      cp $1 $PWD/analog
    else
      exit 1
    fi
  fi
}

export -f sort_pdf &&
  ALL_PDFS=$(mktemp) &&
  for f in $PWD/$1/*.pdf; do echo $f >>$ALL_PDFS; done &&
  parallel --bar sort_pdf :::: "${ALL_PDFS}" ::: $dir_path
