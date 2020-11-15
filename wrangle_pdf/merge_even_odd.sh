#!/usr/bin/env bash
set -e
set -x

pdftk A=$1 B=$2 shuffle B A output merged.pdf