import argparse

from pdflib import Document

parser = argparse.ArgumentParser(
    description="checks of presence of absende of text on images"
)
parser.add_argument("input_files", type=str, nargs="+", help="path to a PDF")
parser.add_argument(
    "--threshold",
    type=int,
    default=0,
    help="maximum number of chars to consider a page empty",
)
parser.add_argument(
    "--absence", action="store_true", help="returnes pages without text"
)

args = parser.parse_args()

for input_file in args.input_files:
    doc = Document(input_file)
    output = []
    num_pages = 0

    for idx, page in enumerate(doc):
        num_pages += 1
        num_chars = sum(map(len, page.lines))
        if num_chars > args.threshold:
            output.append(idx + 1)  # 1-based for PDFs

    if args.absence:
        output = list(set(range(1, num_pages + 1)).difference(set(output)))

    print(" ".join(map(str, output)))
