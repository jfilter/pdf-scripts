import argparse
from pathlib import Path

import cv2
import numpy as np
from tqdm import tqdm

parser = argparse.ArgumentParser(description="crops black or white margin of images")
parser.add_argument("--input", type=str, default="input_images")
parser.add_argument("--output", type=str, default="output_images")
parser.add_argument(
    "--threshold",
    type=int,
    default=80,
)
parser.add_argument("--white", action="store_true")
parser.add_argument("--black", action="store_true")

args = parser.parse_args()

Path(args.output).mkdir(parents=True, exist_ok=True)


def crop_white(img):
    img = 255 * (img < 128).astype(np.uint8)  # To invert the text to white
    coords = cv2.findNonZero(img)  # Find all non-zero points (text)
    return cv2.boundingRect(coords)


def crop_black(img):
    _, thresh = cv2.threshold(img, args.threshold, 255, cv2.THRESH_BINARY)
    contours, _ = cv2.findContours(thresh, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)

    # get contours with highest height + width
    lst_contours = []
    for cnt in contours:
        ctr = cv2.boundingRect(cnt)
        lst_contours.append(ctr)
    return sorted(lst_contours, key=lambda coef: coef[3] + coef[2])[-1]


for img_path in tqdm(list(Path(args.input).glob("*.png"))):
    img = cv2.imread(str(img_path))
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    if args.black:
        rect = crop_black(gray)

    if args.white:
        rect = crop_white(gray)

    x, y, w, h = rect

    crop = img[y : y + h, x : x + w]
    cv2.imwrite(args.output + "/" + img_path.name, crop)
