#!/usr/bin/env bash
set -e
# set -x

number=10
# skip over positional argument of the file(s), thus -gt 1
while [[ "$#" -gt 1 ]]; do
  case $1 in
  -n | --number)
    number="$2"
    shift
    ;;
  *)
    echo "Unknown parameter passed: $1"
    exit 1
    ;;
  esac
  shift
done

find $1 -printf '%s %p\n' | sort -nr | head -$number
