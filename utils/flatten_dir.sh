#!/usr/bin/env bash
set -e
set -x

find $1 -mindepth 2 -type f -exec mv -i '{}' $1 ';'

# delete dirs
find $1 -mindepth 1 -type d -exec rmdir '{' \;
