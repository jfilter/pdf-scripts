#!/usr/bin/env bash
set -e
set -x

pdftk $1 cat even output $1_1.pdf &&
pdftk $1 cat odd output $1_2.pdf