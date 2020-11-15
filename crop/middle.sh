#!/usr/bin/env bash
set -e
set -x

mkdir -p tmp1 tmp2

mutool convert -o tmp1/image%03d.png "$1"
python split_middle.py --input tmp1 --output tmp2
convert tmp2/*.png "$1".split.pdf
rm tmp1/*
rm tmp2/*
