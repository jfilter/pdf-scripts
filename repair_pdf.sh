#!/usr/bin/env bash
set -e
# set -x

################################################################################
# Repair broken PDFs, processing directorys with GNU Parallel
#
# Usage:
#   bash repair_pdf.sh [-v] file_or_directory
#
# Arguments:
#   -c or --check: Checks wheter a PDF was OCRd. If so, do not try to convert it
#                  to keep the text. pdfcairo may remove the text otherwise.
#
#
# Please report issues at https://github.com/jfilter/pdf-scripts/issues
#
# GPLv3, Copyright (c) 2020 Johannes Filter
################################################################################

command_exists() {
  if ! [ -x $($(command -v $1 &>/dev/null)) ]; then
    echo $(error: $1 is not installed.) >&2
    exit 1
  fi
}

check=0
while [[ "$#" -gt 1 ]]; do
  case $1 in
  -c | --check) check=1 ;;
  *)
    echo "Unknown parameter passed: $1"
    exit 1
    ;;
  esac
  shift
done

command_exists mutool && command_exists pdftocairo && command_exists qpdf

clean_pdf() {
  tmp=$1.tmp.pdf
  check=$2
  cp "$1" "$tmp"
  mutool clean "$tmp" "$tmp"

  do_conversion=1
  if ((check == 1)); then
    if ./is_ocrd_pdf.sh -p 5 "$1"; then
      # pdfcairo may remove the text
      echo 'PDF was OCRd, do not try to convert it to keep the text'
      do_conversion=0
    fi
  fi

  if ((do_conversion == 1)); then
    # convert to PDF with pdftocairo (which is using poppler)
    if pdftocairo -pdf "$tmp" "$tmp".2; then
      mv "$tmp".2 "$tmp"
    else
      # TODO: --clean by itself does not alter the PDF, how to convert with qpdf?
      qpdf --clean "$tmp"
      if pdftocairo -pdf "$tmp" "$tmp".2; then
        mv "$tmp".2 "$tmp"
      else
        # gs is last resort, because it may alter the PDF
        gs -o "$tmp".2 -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress "$tmp" &&
          pdftocairo -pdf "$tmp".2 "$tmp"

        if (($? != 0)); then
          echo "gs + pdftocairo had a problem, file it srsly broken"
          echo "$1"
        fi
      fi
    fi
  fi

  # only decrypt files it's needed
  if qpdf --is-encrypted "$tmp"; then
    qpdf --decrypt "$tmp" "$tmp".2 && mv "$tmp".2 "$tmp"
  fi

  mv "$tmp" "$1"
}

if [[ $1 == /* ]]; then
  input=$1
else
  input=$PWD/$1
fi

if [[ -d $input ]]; then
  # directory of PDFs
  command_exists parallel
  export -f clean_pdf
  ALL_PDFS=$(mktemp)
  for f in $input/*.pdf; do echo $f >>$ALL_PDFS; done
  parallel --bar clean_pdf :::: "${ALL_PDFS}" ::: $check
elif [[ -f $input ]]; then
  # single pdf
  clean_pdf "$input" $check
else
  echo "error: please provide some valid input file(s)"
  exit 1
fi
