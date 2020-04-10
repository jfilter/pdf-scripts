#!/usr/bin/env bash
set -e
# set -x

# still WIP, very opiniated

# not sure what --dpi does

# parse arguments
# h/t https://stackoverflow.com/a/33826763/4028896

optimize=1 && force_ocr=0 && clean=0 && args=""

# not all languages are supported with the Docker image
# https://ocrmypdf.readthedocs.io/en/latest/docker.html#adding-languages-to-the-docker-image
# https://github.com/tesseract-ocr/tesseract/blob/master/doc/tesseract.1.asc#languages
# deu - German
# spa - Spanish
# fra - French
# por - Portuguese
# chi_sim - Chinese simplified
lang="eng"

# skip over positional argument of the file(s), thus -gt 1
while [[ "$#" -gt 1 ]]; do
  case $1 in
  -o | --optimize)
    optimize="$2"
    shift
    ;;
  -f | --force)
    force_ocr="$2"
    shift
    ;;
  -l | --language)
    lang="$2"
    shift
    ;;
  -a | --args)
    dpi="$2"
    shift
    ;;
  -c | --clean) clean=1 ;;
  *)
    echo "Unknown parameter passed: $1"
    exit 1
    ;;
  esac
  shift
done

# in $7 are the remaining args
do_ocr() {
  tmpdir=$(mktemp -d)
  cp $1 $tmpdir/
  fn=$(basename -- "$1")
  echo $fn

  if (($4 == 0)); then
    force_txt="--skip-text --deskew"
  elif (($4 == 1)); then
    force_txt="--redo-ocr"
  elif (($4 == 2)); then
    force_txt="--force-ocr --deskew"
  else
    echo "wrong input for --force"
    exit 1
  fi

  clean_txt=""
  if (($5 == 1)); then
    clean_txt="--remove-background --clean-final"
  fi

  opt="$3"
  if (($opt == 3)); then
    opt="3 --jbig2-lossy"
  fi

  docker run --rm -v "$tmpdir:/data" jbarlow83/ocrmypdf -l $6 --pdf-renderer hocr --output-type pdf --tesseract-timeout=0 --clean $force_txt $clean_txt $7 --optimize $opt /data/$fn /data/$fn.out.pdf && mv -f $tmpdir/$fn.out.pdf $2/$fn
}

full_path="$PWD/$1"

mkdir -p $PWD/out

if [[ -d full_path ]]; then
  # directory of PDFs, need to create tmp file to store all args
  for f in $full_path/*.pdf; do
    do_ocr $f $PWD/out $optimize $force_ocr $clean $lang $args
  done
elif [[ -f $full_path ]]; then
  # single pdf
  do_ocr $full_path $PWD/out $optimize $force_ocr $clean $lang $args
else
  echo "error: please provide some valid input file(s)"
  exit 1
fi
