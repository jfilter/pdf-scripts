#!/usr/bin/env bash
set -e
# set -x

################################################################################
# Check if a PDF was scanned or created digitally, works on OCRd PDFs
#
# Usage:
#   bash is_scanned_pdf.sh [-p] file
#
#   Exit 0: Yes, file is a scanned PDF
#   Exit 1: No, file was created digitally
#
# Arguments:
#   -p or --pages: pos. integer, only consider first N pages 
#
# Please report issues at https://github.com/jfilter/pdf-scripts/issues
#
# GPLv3, Copyright (c) 2020 Johannes Filter
################################################################################

# parse arguments
# h/t https://stackoverflow.com/a/33826763/4028896
max_pages=-1
# skip over positional argument of the file(s), thus -gt 1
while [[ "$#" -gt 1 ]]; do case $1 in
  -p|--pages) max_pages="$2"; shift;;
  *) echo "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

# increment to make it easier with page numbering
max_pages=$((max_pages++))

command_exists () {
  if ! [ -x `$(command -v $1 &> /dev/null)` ]; then
    echo `error: $1 is not installed.` >&2
    exit 1
  fi
}

command_exists mutool && command_exists gs && command_exists compare
command_exists pdfinfo

orig=$PWD
num_pages=$(pdfinfo $PWD/$1 | grep Pages | awk '{print $2}')

echo $num_pages

echo $max_pages

if (( ($max_pages > 1) && ($max_pages < $num_pages) )); then
  num_pages=$max_pages
fi

cd $(mktemp -d)

for ((i=1;i<=num_pages;i++)); do
  mkdir -p output/$i && echo $i
done

# important to filter text on output of GS (tmp1), cuz GS alters input PDF...
gs -o tmp1.pdf -sDEVICE=pdfwrite -dLastPage=$num_pages $orig/$1 &>/dev/null
gs -o tmp2.pdf -sDEVICE=pdfwrite -dFILTERTEXT tmp1.pdf &>/dev/null
mutool convert -o output/%d/1.png tmp1.pdf 2>/dev/null
mutool convert -o output/%d/2.png tmp2.pdf 2>/dev/null

for ((i=1;i<=num_pages;i++)); do
  echo $i
  # difference in pixels, if 0 there are the same pictures
  # discard diff image
  if ! compare -metric AE output/$i/1.png output/$i/2.png null: 2>&1; then
    echo " pixels difference, not a scanned PDF, mismatch on page $i"
    exit 1
  fi
done
