#!/usr/bin/env bash
set -e
# set -x

################################################################################
# Removes metadata and optionally set author and title
#
# Usage:
#   bash clean_metdata_pdf.sh [-t] [-a] file.pdf
#
# Arguments:
#   -t or --title: new title
#   -a or --author: new author
##
# Please report issues at https://github.com/jfilter/pdf-scripts/issues
#
# related: https://0xacab.org/jvoisin/mat2
#
# GPLv3, Copyright (c) 2020 Johannes Filter
################################################################################


title="" && author=""
while [[ "$#" -gt 2 ]]; do
	case $1 in
	-t | --title)
		title="$2"
		shift
		;;
	-a | --author)
		author="$2"
		shift
		;;
	*)
		echo "Unknown parameter passed: $1"
		exit 1
		;;
	esac
	shift
done

# remove all metdata
exiftool -all= "$1"

# set only the most important
exiftool -Title="$title" -Author="$author" "$1"

# exitool only adds new data, but does not remove old one. The following command
# fixes the PDF ultimately.
qpdf --linearize "$1" "$1".tmp && mv "$1".tmp "$1"
