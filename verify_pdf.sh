#!/usr/bin/env bash
set -e
# set -x

################################################################################
# Verify integrity of PDFs, processing directorys with GNU Parallel
#
# Usage:
#   bash verify_pdf.sh [-i] [-t] [-q] file_or_directory
#
# Arguments:
#   -i or --info: check pdf with `pdfinfo`, general fast check
#   -t or --text: check pdf with `pdftotext`, tries to extract text for
#                 each page
#   -q or --qpdf: check pdf with `qpdf --check` and `qpdf --is-encrypted`,
#                 detects, e.g., locked (password protected) PDFs
# 
#   NB: -it is not working, use -i -t
#
# Please report issues at https://github.com/jfilter/pdf-scripts/issues
#
# GPLv3, Copyright (c) 2020 Johannes Filter
################################################################################


# parse arguments
# h/t https://stackoverflow.com/a/33826763/4028896
do_info=0 && do_text=0 && do_qpdf=0

# skip over positional argument of the file(s), thus -gt 1
while [[ "$#" -gt 1 ]]; do case $1 in
  -i|--info) do_info=1;;
  -t|--text) do_text=1;;
  -q|--qpdf) do_qpdf=1;;
  *) echo "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

# default: enable all
if (( ($do_info + $do_text + $do_qpdf) == 0 )); then
  do_info=1 && do_text=1 && do_qpdf=1
fi

command_exists () {
  if ! [ -x `$(command -v $1 &> /dev/null)` ]; then
    echo `error: $1 is not installed.` >&2
    exit 1
  fi
}

check_pdfinfo () {
  if ! pdfinfo "$1" &> /dev/null; then
    echo "$1" is broken, pdfinfo
  fi
}

# send text to stdout
check_pdftotext () {
  if ! pdftotext "$1" - &> /dev/null; then
    echo "$1" is broken, pdftotext
  fi
}

# todo: better error code handling, code 3 is just warning
check_qpdf () {
  qpdf --check "$1" &> /dev/null
  # echo $?
  if (( $? == 2 )) ||  qpdf --is-encrypted $1 &> /dev/null; then
    echo "$1" is broken, qpd
  fi
}

echo "-----------------------"
echo "checking PDFs with..."
(($do_info == 1)) && echo "pdfinfo" && command_exists pdfinfo
(($do_text == 1)) && echo "pdftotext" && command_exists pdftotext
(($do_qpdf == 1)) && echo "qpdf" && command_exists qpdf
echo "-----------------------"

# $1 is the file and the following arguments the options
check () {
  (($2 == 1)) && check_pdfinfo $1
  (($3 == 1)) && check_pdftotext $1
  (($4 == 1)) && check_qpdf $1
}

if [[ -d $PWD/$1 ]]; then
  # directory of PDFs, need to create tmp file to store all args
  command_exists parallel &&
  export -f check && export -f check_pdfinfo && export -f check_pdftotext &&
  export -f check_qpdf &&
  ALL_PDFS=$(mktemp) &&
  for f in $PWD/$1/*.pdf; do echo $f >> $ALL_PDFS; done &&
  parallel --bar check :::: "${ALL_PDFS}" ::: $do_info ::: $do_text ::: $do_qpdf
elif [[ -f $PWD/$1 ]]; then
  # single pdf
  check $PWD/$1 $do_info $do_text $do_qpdf
else
  echo "error: please provide some valid input file(s)"
  exit 1
fi
