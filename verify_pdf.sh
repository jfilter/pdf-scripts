
#!/usr/bin/env bash
set -e
# set -x

# Verify PDF file
#
# Parameter :
#   $1 - single PDF or a folder of multiple PDFs
#

command_exists () {
  if ! [ -x `$(command -v $1 &> /dev/null)` ]; then
    echo `error: $1 is not installed.` >&2
    exit 1
  fi
}

command_exists pdfinfo && command_exists pdftotext && command_exists qpdf


check_pdfinfo () {
  if ! pdfinfo "$1" &> /dev/null; then
    echo "$1" is broken, pdfinfo
  fi
}

check_pdftotext () {
  if ! pdftotext "$1" &> /dev/null; then
    echo "$1" is broken, pdftotext
  fi
}

# todo: better error code handling, code 3 is just warning
check_qpdf () {
  if ! qpdf --check "$1" &> /dev/null; then
    echo "$1" is broken, qpd
  fi
}

check () {
  check_pdfinfo $1 && check_pdftotext $1 && check_qpdf $1
}

if [[ -d $PWD/$1 ]]; then
  # directory of PDFs
  command_exists parallel &&
  export -f check && export -f check_pdfinfo && export -f check_pdftotext && export -f check_qpdf
  ALL_PDFS=$(mktemp) &&
  for f in $PWD/$1/*.pdf; do echo $f >> $ALL_PDFS; done &&
  cat "${ALL_PDFS}" | parallel --bar check
elif [[ -f $PWD/$1 ]]; then
  # single pdf
  check $PWD/$1
else
  echo "error: please provide some valid input file(s)"
  exit 1
fi

