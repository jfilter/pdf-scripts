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
#   -v or --verbose: TODO, not yet implemented
# 
#   NB: -it is not working, use -i -t
#
# Please report issues at https://github.com/jfilter/pdf-scripts/issues
#
# GPLv3, Copyright (c) 2020 Johannes Filter
################################################################################

command_exists () {
  if ! [ -x `$(command -v $1 &> /dev/null)` ]; then
    echo `error: $1 is not installed.` >&2
    exit 1
  fi
}

command_exists mutool && command_exists pdftocairo && command_exists qpdf


clean_pdf () {
  tmp=$1.tmp.pdf
  cp $1 $tmp
  mutool clean $tmp $tmp

  # convert to PDF with pdftocairo (which is using poppler)
  if pdftocairo -pdf $tmp $tmp.2; then
    mv $tmp.2 $tmp
  else
    qpdf --clean $tmp
    if pdftocairo -pdf $tmp $tmp.2; then
      mv $tmp.2 $tmp
    else
      # gs is last resort, because it may alter the PDF
      gs -o $tmp.2 -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress $tmp &&
      pdftocairo -pdf $tmp.2 $tmp

      if (($? != 0)); then
        echo "gs + pdftocairo had a problem, file it srsly broken"
        echo $1
      fi
    fi
  fi

  # only decrypt files it's needed
  if qpdf --is-encrypted $tmp; then
    qpdf --decrypt $tmp $tmp.2 && mv $tmp.2 $tmp
  fi

  mv $tmp $1
}

if [[ -d $PWD/$1 ]]; then
  # directory of PDFs
  command_exists parallel &&
  export -f clean_pdf &&
  ALL_PDFS=$(mktemp) &&
  for f in $PWD/$1/*.pdf; do echo $f >> $ALL_PDFS; done &&
  cat "${ALL_PDFS}" | parallel --bar clean_pdf
elif [[ -f $PWD/$1 ]]; then
  # single pdf
  clean_pdf $PWD/$1
else
  echo "error: please provide some valid input file(s)"
  exit 1
fi
