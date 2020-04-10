#!/usr/bin/env bash
set -e
set -x

# still WIP

dir_path=$(dirname $0)

if [[ $1 == /* ]]; then
  input=$1
else
  input=$PWD/$1
fi

reduce() {
  # 1.
  $2/compress_pdf.sh $1 $1.tmp && mv $1.tmp $1

  # 2.
  tmpdir=$(mktemp -d)
  cp $1 $tmpdir/
  fn=$(basename -- "$1")
  docker run --rm -v "$tmpdir:/workdir" -u "$(id -u):$(id -g)" ptspts/pdfsizeopt pdfsizeopt --use-pngout=no $fn $fn.tmp
  mv -f $tmpdir/$fn.tmp $1
}

if [[ -d $input ]]; then
  export -f reduce
  ALL_PDFS=$(mktemp)
  for f in $input/*.pdf; do echo $f >>$ALL_PDFS; done
  parallel --bar reduce :::: "${ALL_PDFS}" ::: $dir_path
elif [[ -f $input ]]; then
  # single pdf
  reduce $input $dir_path
else
  echo "error: please provide some valid input file(s)"
  exit 1
fi
