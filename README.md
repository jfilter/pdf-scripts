# PDF Scripts

Scripts (mostly Bash) to repair, verify, OCR, compress (etc.) PDFs.

*Currently in beta status, so except backward-incompatible changes.*

## Install

You need to have [Bash](https://en.wikipedia.org/wiki/Bash_(Unix_shell)) installed.

The scripts use several software libraries. [setup.sh](./setup.sh) installs them for macOS (via brew) or Ubuntu/Debian.


## Usage

1. Go to root of this repository: `cd pdf-scripts`
2. Excute script `./pipeline.sh -l deu /path/to/document-in-german.pdf`

Please refer to the scripts for the command-line arguments and options. NB: It's not possible to combine options, e.g., use `-x -y` instead of `-xy`.

Most scripts work on individual PDFs as well as on folders full of PDFs.

## Overview

### [ocr_pdf.sh](./ocr_pdf.sh)

OCR PDFs with [OCRmyPDF](https://github.com/jbarlow83/OCRmyPDF).

### [repair_pdf.sh](./repair_pdf.sh)

Using: `pdftocairo` from [poppler](<https://en.wikipedia.org/wiki/Poppler_(software)>), `mutool clean` from [MuPDF](https://en.wikipedia.org/wiki/MuPDF), [qpdf](https://en.wikipedia.org/wiki/QPDF)

Caveat: May remove text in OCRd PDFs. Use `--check` to check for OCRd text in order to preserve it.


### [verify_pdf.sh](./verify_pdf.sh)

Checks if text can be extracted (if it's already on the PDF)

### [compress_pdf.sh](./compress_pdf.sh)

Using [ghostcript](https://askubuntu.com/a/256449) to compress images in PDFs.

### [reduce_size_pdf.sh](reduce_size_pdf.sh)

Use [compress_pdf.sh](./compress_pdf.sh) but also [pdfsizeopt](https://github.com/pts/pdfsizeopt) to reduze file size of PDFs.

### [clean_metadata_pdf.sh](./clean_metadata_pdf.sh)

Remove metadata with [exiftool](https://exiftool.org/).

### [is_ocrd_pdf.sh](./is_ocrd_pdf.sh)

Detect OCRd PDFs. See also [sort_ocrd_pdfs.sh](sort_ocrd_pdfs.sh) to sort PDFs.

### [pipeline.sh](./pipeline.sh)

Combining several of the above scripts.

## FAQ

### Why Bash?

Bash is still the most-used shell. And the scipts comprise mostly of simple conditionals and sequences of CLI commands. This could also be done with Python's `psutil` but this would add yet another layer. However, at some point, I most probable port the scripts to simple POSIX-Shell.

## Related Work

- https://dangerzone.rocks/
- https://0xacab.org/jvoisin/mat2
- https://github.com/NicolasBernaerts/ubuntu-scripts/blob/master/pdf/pdf-repair
- https://scantailor.org/ (unmantained)
- [more tools for PDF in my blog post](https://johannesfilter.com/python-and-pdf-a-review-of-existing-tools/)

## Development

- focus on Bash v4+
- write Python 3.6+ scripts if Bash gets too complicated
- use Docker images if available
- should run on the major Unix-like OSs (Linux (e.g. Ubuntu), macOS)
- format code with [shfmt](https://github.com/mvdan/sh#shfmt), e.g., extension for [VS Code](https://github.com/foxundermoon/vs-shell-format)
- lint scripts with [shellcheck](https://github.com/koalaman/shellcheck), e.g., extension for [VS Code](https://github.com/timonwong/vscode-shellcheck)

## License

GPLv3.
