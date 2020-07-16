#!/usr/bin/env python3

import re
import shutil
import urllib.request
from argparse import ArgumentParser
from pathlib import Path

import fasttext
import pdftotext
from tqdm import tqdm

parser = ArgumentParser(description="checks for presence of absence of text on images")
parser.add_argument("input_folder", type=str, help="path to a folder with PDFs")

args = parser.parse_args()

# smaller modell
pretrained_lang_model = "lid.176.ftz"

if not Path(pretrained_lang_model).is_file():
    get_model = urllib.request.URLopener()
    get_model.retrieve(
        f"https://dl.fbaipublicfiles.com/fasttext/supervised-models/{pretrained_lang_model}",
        pretrained_lang_model,
    )

model = fasttext.load_model(pretrained_lang_model)


def predict_lang(text, k=1):
    output = model.predict(text, k=k)
    label = output[0][0].replace("__label__", "")
    return label


def add_parent_to_path(p, new_parent):
    new_text = str(p.parent.parent) + f"/{p.parent.stem}_{new_parent}/" + p.name
    new_p = Path(new_text)
    new_p.parent.mkdir(parents=True, exist_ok=True)
    return new_p


for p in tqdm(list(Path(args.input_folder).glob("*.pdf"))):
    with open(str(p), "rb") as f:
        pdf = pdftotext.PDF(f)
        text = " ".join(pdf)

    # replace all kind of whitespace
    text = re.sub(r"\s+", " ", text)
    label = predict_lang(text)

    # copy to new location
    shutil.copy(p, add_parent_to_path(p, label))
