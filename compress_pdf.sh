#!/usr/bin/env bash
set -e
set -x

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
#                  the compression. Defaults to 3.
#
# Please report issues at https://github.com/jfilter/pdf-scripts/issues
#
# GPLv3, Copyright (c) 2020 Johannes Filter
################################################################################

level=3 && inplace=1
while [[ "$#" -gt 2 ]]; do
	case $1 in
	-c | --copy) inplace=0 ;;
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

# TODO: is default really level 1? Or should it be level 2?
compress_pdf() {
	case "$2" in
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
		echo "Choose a number between 1 (low compression) and 5 (high compression)"
		exit 1
		;;
	esac

	# TODO: Are those parameters helpful? dDetectDuplicateImages -dCompressFonts=true -r150

	gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 \
		-dPDFSETTINGS=/${compression_setting} -dNOPAUSE -dQUIET -dBATCH \
		-sOutputFile=$1.tmp $1
	if [ "$?" -ne 0 ]; then
		echo "Failed to compress input PDF." >&2 && exit 2
	fi

	size_before=$(get_file_size $1)
	size_after=$(get_file_size $1.tmp)

	if ((size_before < size_after)); then
		rm $1.tmp
		echo "size increased, aborting. before: $size_before after: $size_after"
	else
		# overwrite or new file
		(($3 == 1)) && mv $1.tmp $1
		(($3 == 0)) && mv $1.tmp $1.out.pdf
		echo "size reduced from $size_before to $size_after"
	fi
}


if [[ $1 == /* ]]; then
  input=$1
else
  input=$PWD/$1
fi


if [[ -d input ]]; then
  # directory of PDFs
  export -f compress_pdf
  ALL_PDFS=$(mktemp)
  for f in $input/*.pdf; do echo $f >>$ALL_PDFS; done
  parallel --bar compress_pdf :::: "${ALL_PDFS}" ::: $level ::: $inplace


elif [[ -f $input ]]; then
  # single pdf
  compress_pdf $input $level $inplace
else
  echo "error: please provide some valid input file(s)"
  exit 1
fi
