#!/usr/bin/env bash
set -e

# Automatically split up double pages to single pages by using the orientatio of each page

# extract page number and page width
page_pattern="^Page[^[:digit:]]*([[:digit:]]+) size[^[:digit:]]*([[:digit:]]+).[[:digit:]]+[^[:digit:]]*([[:digit:]]+).[[:digit:]]+[^[:digit:]]*"

num_pages=$(qpdf --show-npages $1)

pdfinfo -f 1 -l $num_pages $1 | while read -r line; do
  if [[ $line =~ $page_pattern ]]; then
    pn=${BASH_REMATCH[1]}
    echo "working on page $pn"

    qpdf $1 --pages . $pn -- $1.tmp.$pn.pdf

    # x or y depends, todo: programatically
    if [[ ${BASH_REMATCH[2]} -gt ${BASH_REMATCH[3]} ]]; then
      # mutool poster -x 2 $1.tmp.$pn.pdf $1.tmp.$pn.pdf &&
      mutool poster -x 2 $1.tmp.$pn.pdf $1.tmp.$pn.pdf &&
        echo 'doubled page'
    else
      echo 'single page'
    fi
  fi
done

files=''
for i in $(seq 1 $num_pages); do
  tmp=$1.tmp.$i.pdf
  files="$files$tmp "
done

echo "$files"
qpdf --empty --pages $files -- "$1".final.pdf &&
  rm "$1".tmp.*.pdf
