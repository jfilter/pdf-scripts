#!/usr/bin/env bash
set -e

################################################################################
# Compress images in PDFs with GhostScript.
# Information about the 5 level of compression:https://askubuntu.com/a/256449
#
# Built upon work by Erik Westrup: https://github.com/erikw/dotfiles/blob/personal/bin/pdf_compress.sh
#
# Usage:
#   bash compress_pdf.sh [-l] input.pdf output.pdf
#
# Arguments:
#   -l or --level: level of compression (1-5), the higher the harder
#                  the compression. Defaults to 4.
#
# Please report issues at https://github.com/jfilter/pdf-scripts/issues
#
# GPLv3, Copyright (c) 2020 Johannes Filter
################################################################################

level=4
while [[ "$#" -gt 2 ]]; do
	case $1 in
	-l | --level)
		level="$2"
		shift
		;;
	*)
		echo "Unknown parameter passed: $1"
		exit 1
		;;
	esac
	shift
done

get_file_size() {
	file="$1"
	du "$file" | awk '{print $1}'
}

compress_pdf() {
	case "$3" in
	1)
		compression_setting="default"
		;;
	2)
		compression_setting="printer"
		;;
	3)
		compression_setting="prepress"
		;;
	4)
		compression_setting="ebook"
		;;
	5)
		compression_setting="screen"
		;;
	*)
		echo "Choose a number between 1 and 5"
		exit 1
		;;
	esac

	gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 \
		-dPDFSETTINGS=/${compression_setting}-dNOPAUSE -dQUIET -dBATCH \
		-sOutputFile=$1.tmp $1
	if [ "$?" -ne 0 ]; then
		echo "Failed to compress input PDF." >&2 && exit 2
	fi

	size_before=$(get_file_size $1)
	size_after=$(get_file_size $1.tmp)

	if ((size_before < size_aft)); then
		echo "size increased, aborting. before: $size_before after: $size_after"
		rm $1.tmp
	else
		mv $1.tmp $2
		echo "size reduced from $size_before to $size_after"
	fi
}

compress_pdf $1 $2 $level
