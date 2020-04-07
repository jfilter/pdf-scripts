#!/usr/bin/env bash
set -e
set -x

# https://unix.stackexchange.com/a/52816
# find /dir1 -mindepth 2 -type f -exec mv -t /dir1 -i '{}' +

find $1 -mindepth 2 -type f -exec mv -i '{}' $1 ';'

# delete dirs
find $1 -mindepth 1 -type d -exec rmdir "{}" \;