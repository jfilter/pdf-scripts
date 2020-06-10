# PDF Scripts

Scripts to repair, verify, OCR, compress (etc.) PDFs.

## Overview

### [repair_pdf.sh](./repair_pdf.sh)

Using: `pdftocairo` from [poppler](<https://en.wikipedia.org/wiki/Poppler_(software)>), `mutool clean` from [MuPDF](https://en.wikipedia.org/wiki/MuPDF), [qpdf](https://en.wikipedia.org/wiki/QPDF)

Caveat: May remove OCR.

Related Work: https://github.com/NicolasBernaerts/ubuntu-scripts/blob/master/pdf/pdf-repair

### [verify_pdf.sh](./verify_pdf.sh)

Checks if text can be extracted (if it's already on the PDF)

### [compress_pdf.sh](./compress_pdf.sh)

Using ghoscript to compress images in PDFs.

### [reduce_size_pdf.sh](reduce_size_pdf.sh)

Use [compress_pdf.sh](./compress_pdf.sh) but also [pdfsizeopt](https://github.com/pts/pdfsizeopt) to reduze file size of PDFs.

### [ocr_pdf](./ocr_pdf.sh)

OCR PDFs with [OCRmyPDF](https://github.com/jbarlow83/OCRmyPDF).

### [clean_metadata_pdf.sh](clean_metadata_pdf.sh)

Remove metadata with [exiftool](https://exiftool.org/).

### [pipeline.sh](./repair_pdf.sh)

Combining several of the above scripts.

Caveat: Right now the 'repair' step occasionally removes the OCR is available.

### [is_ocrd_pdf.sh](is_ocrd_pdf.sh)

Detect OCRd PDFs. See also [sort_ocrd_pdfs.sh](sort_ocrd_pdfs.sh) to sort PDFs.

## Development

- focus on Bash v4+
- Write Python 3.6+ scripts if Bash gets too complicated
- use Docker images if available
- should run on the major Unix-like OSs (Linux (e.g. Ubuntu), macOS)
- format code with [shfmt](https://github.com/mvdan/sh#shfmt), e.g., extension for [VS Code](https://github.com/foxundermoon/vs-shell-format)
- lint scripts with [shellcheck](https://github.com/koalaman/shellcheck), e.g., extension for [VS Code](https://github.com/timonwong/vscode-shellcheck)

## License

GPLv3.
