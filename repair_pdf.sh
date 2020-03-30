
#!/usr/bin/env bash
set -e
# set -x

# Repair broken PDF file
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

command_exists mutool && command_exists pdftocairo && command_exists qpdf


clean_pdf () {
  tmp=$1.tmp.pdf
  cp $1 $tmp
  mutool clean $tmp $tmp

  # sometimes pdftocairo files but the file is still working
  if pdftocairo -pdf $tmp $tmp.2; then
    mv $tmp.2 $tmp
  else
    echo "pdftocairo had a problem"
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

