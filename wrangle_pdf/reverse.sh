#!/usr/bin/env bash
set -e
set -x

# qpd: https://askubuntu.com/a/1127083

pdftk $1 cat end-1 output $1.reversed