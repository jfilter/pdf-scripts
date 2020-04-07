#!/usr/bin/env bash


docker run --rm -v "$PWD:/workdir" -u "$(id -u):$(id -g)" ptspts/pdfsizeopt pdfsizeopt --use-pngout=no $1 $1.small.pdf