# PDF Scripts

Scripts to repair, verify, OCR (etc.) PDFs. It still WIP so use it with care.

## Scripts included

### [repair_pdf.sh](./repair_pdf.sh)

- `pdftocairo` from [poppler](<https://en.wikipedia.org/wiki/Poppler_(software)>)
- `mutool clean` from [MuPDF](https://en.wikipedia.org/wiki/MuPDF)
- `qpdf` from [QDF](https://en.wikipedia.org/wiki/QPDF)

#### Related Work

- https://github.com/NicolasBernaerts/ubuntu-scripts/blob/master/pdf/pdf-repair

### [verify_pdf.sh](./verify_pdf.sh)

- `qpdf --check`
- `pdfinfo`
- `pdftotext`

## Development

- focus on Bash, don't aim to support lower versions of Bash
- should run on the major Unix-like OSs (Linux (e.g. Ubuntu), macOS)
- format code with [shfmt](https://github.com/mvdan/sh#shfmt), e.g., extension for [VS Code](https://github.com/foxundermoon/vs-shell-format)
- use Docker images if available

## License

GPLv3.
