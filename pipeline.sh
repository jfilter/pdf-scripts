#!/usr/bin/env bash
set -e
set -x

################################################################################
# Common steps to create an OCRd, size-optimized PDF
#
# Usage:
#   bash pipeline.sh [-l] [-o] folder_with_pdfs
#
# Arguments:
#   -l or --language: language for OCR, defaults to `eng`
#   -o or --optimize: level of file optimization, 0 to deactivate size optimization
#                     1 should optimize without harm, 2 and 3 are compression the files harder
#
# Please report issues at https://github.com/jfilter/pdf-scripts/issues
#
# GPLv3, Copyright (c) 2020 Johannes Filter
################################################################################

lang='eng' && optimize=2
while [[ "$#" -gt 1 ]]; do
  case $1 in
  -l | --language)
    lang="$2"
    shift
    ;;
  -o | --optimize)
    optimize="$2"
    shift
    ;;
  *)
    echo "Unknown parameter passed: $1"
    exit 1
    ;;
  esac
  shift
done

if [[ $1 == /* ]]; then
  input=$1
else
  input=$PWD/$1
fi

echo '1. normalizing files'
bash utils/normalize_files.sh "$input"

echo '2. repairing pdfs'
bash repair_pdf.sh -c "$input"

echo '3. ocr PDFs'
bash ocr_pdf.sh -l "$lang" -o $optimize "$input"

if ((optimize > 0)); then
  echo '4. reduce file size'
  bash reduce_size_pdf.sh -l $((optimize+1)) "$input"
fi

echo '5. verify PDF'
bash verify_pdf.sh "$input"
