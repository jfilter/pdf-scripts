#!/usr/bin/env bash
set -e
# set -x

# set correct file permissions https://stackoverflow.com/a/28993800/4028896
# normalize filenames with detox https://github.com/dharple/detox

# only work the absulute path
if [[ $1 == /* ]]; then
  input=$1
else
  input=$PWD/$1
fi

detox $input
find $input -type f -print0 | xargs -0 chmod 0664
find $input -type d -print0 | xargs -0 chmod 0775
