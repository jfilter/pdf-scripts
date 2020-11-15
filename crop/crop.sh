#!/usr/bin/env bash
set -e
set -x

mkdir -p tmp1 tmp2

mutool convert -o tmp1/image%03d.png "$1"
python crop_images.py --white --input tmp1 --output tmp2
python crop_images.py --black --input tmp2 --output tmp1 --threshold 80
convert tmp1/*.png "$1".cropped.pdf
rm tmp1/*
rm tmp2/*

