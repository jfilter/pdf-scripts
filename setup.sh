#!/usr/bin/env bash
set -e
set -x

# post-installation: run `parallel --citation`

command_exists() {
  if ! [ -x $($(command -v $1 &>/dev/null)) ]; then
    echo $(error: $1 is not installed.) >&2
    exit 1
  fi
}

# for macos
if [ "$(uname)" == "Darwin" ]; then
  command_exists brew
  command_exists docker

  brew install parallel ghostscript mupdf-tools qpdf poppler detox exiftool imagemagick
fi

# for centos
if [ -f /etc/redhat-release ]; then
  echo "not yet implemented"
  exit 1
fi

# for ubuntu
if [ -f /etc/lsb-release ]; then
  # not sure, TODO
  apt-get update && apt-get install -y parallel ghostscript mupdf-tools qpdf poppler-utils detox libimage-exiftool-perl imagemagick
  apt-get install -y containerd docker.io
fi
