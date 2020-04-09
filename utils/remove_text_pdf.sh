#!/usr/bin/env bash
set -e
# set -x

gs -o $PWD/$1.tmp -sDEVICE=pdfwrite -dFILTERTEXT $PWD/$1 &&
  mv $PWD/$1.tmp $PWD/$1
