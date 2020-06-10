#!/usr/bin/env bash
set -e
# set -x

################################################################################
# Reduce PDF file size by compression and optimsation
#
# Usage:
#   bash reduce_file_size.sh [-l] file_or_directory
#
# Arguments:
#   -l or --level: level of compression (1-5), the higher the harder
#                  the compression. Defaults to 3.
#
# Please report issues at https://github.com/jfilter/pdf-scripts/issues
#
# GPLv3, Copyright (c) 2020 Johannes Filter
################################################################################

level=3
while [[ "$#" -gt 2 ]]; do
  case $1 in
  -l | --level)
    level="$2"
    shift
    ;;
  *)
    echo "Unknown parameter passed: $1"
    exit 1
    ;;
  esac
  shift
done

dir_path=$(dirname "$0")

if [[ $1 == /* ]]; then
  input=$1
else
  input=$PWD/$1
fi

reduce() {
  # 1. reduce image quality
  if ((level > 0)); then
    "$2"/compress_pdf.sh -l $level "$1"
  fi

  # 2. reduce PDF size, --use-pngout=no to speed things up
  tmpdir=$(mktemp -d)
  cp "$1" "$tmpdir"/
  fn=$(basename -- "$1")
  docker run --rm -v "$tmpdir:/workdir" -u "$(id -u):$(id -g)" ptspts/pdfsizeopt pdfsizeopt --use-pngout=no "$fn" "$fn".tmp
  mv -f "$tmpdir"/"$fn".tmp "$1"
}

if [[ -d $input ]]; then
  export -f reduce
  ALL_PDFS=$(mktemp)
  for f in "$input"/*.pdf; do echo "$f" >> "$ALL_PDFS"; done
  parallel --bar reduce :::: "${ALL_PDFS}" ::: "$dir_path"
elif [[ -f $input ]]; then
  # single pdf
  reduce "$input" "$dir_path"
else
  echo "error: please provide some valid input file(s)"
  exit 1
fi
