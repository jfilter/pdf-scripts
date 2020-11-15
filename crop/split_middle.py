import argparse
import math
from pathlib import Path

import cv2
import numpy as np
from tqdm import tqdm

parser = argparse.ArgumentParser(description="crops black or white margin of images")
parser.add_argument("--input", type=str, default="input_images")
parser.add_argument("--output", type=str, default="output_images")

args = parser.parse_args()

Path(args.output).mkdir(parents=True, exist_ok=True)


def line_by_points(p1, p2):
    A = p1[1] - p2[1]
    B = p2[0] - p1[0]
    C = p1[0] * p2[1] - p2[0] * p1[1]
    return A, B, -C


def intersection(L1, L2):
    """NB: returns ints"""
    D = L1[0] * L2[1] - L1[1] * L2[0]
    Dx = L1[2] * L2[1] - L1[1] * L2[2]
    Dy = L1[0] * L2[2] - L1[2] * L2[0]
    if D != 0:
        x = Dx / D
        y = Dy / D
        return int(x), int(y)
    else:
        return None


def crop_and_save(img, pts, fn):
    """https://stackoverflow.com/a/48301735/4028896"""

    ## (1) Crop the bounding rect
    rect = cv2.boundingRect(pts)
    x, y, w, h = rect
    croped = img[y : y + h, x : x + w].copy()

    ## (2) make mask
    pts = pts - pts.min(axis=0)

    mask = np.zeros(croped.shape[:2], np.uint8)
    cv2.drawContours(mask, [pts], -1, (255, 255, 255), -1, cv2.LINE_AA)

    ## (3) do bit-op
    dst = cv2.bitwise_and(croped, croped, mask=mask)

    ## (4) add the white background
    bg = np.ones_like(croped, np.uint8) * 255
    cv2.bitwise_not(bg, bg, mask=mask)
    dst2 = bg + dst

    cv2.imwrite(fn, dst2)


def split_middle_line(image_path, buffer_perc=0.01):
    img = cv2.imread(str(image_path))

    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    edges = cv2.Canny(gray, 20, 30)

    half_height = int(img.shape[0] * 0.5)
    width = img.shape[1]
    height = img.shape[0]

    lines = cv2.HoughLinesP(
        image=edges,
        rho=1,
        theta=np.pi / 1000.0,
        threshold=50,
        minLineLength=half_height,
        maxLineGap=half_height,
    )

    # find middle-ish lines
    line_candidates = []
    for line in lines:
        for x1, y1, x2, y2 in line:
            if x2 == x1:
                continue

            angle = int(math.atan((y1 - y2) / (x2 - x1)) * 180 / math.pi)
            if not 75 < angle < 105:
                continue
            if not 0.4 < ((x2 + x1) / 2) / width < 0.6:
                continue
            line_candidates.append(line)

    # choose longest or take the default middle line
    if len(line_candidates) > 0:
        line_candidates = sorted(
            line_candidates, key=lambda x: x[0][1] - x[0][3], reverse=True
        )
        x1, y1, x2, y2 = line_candidates[0][0]
        # cv2.line(img, (x1, y1), (x2, y2), (255, 0, 0), 5)

    else:
        x1 = int(width / 2)
        x2 = x1
        y1 = 0
        y2 = height

    l1 = line_by_points((x1, y1), (x2, y2))

    l_top = line_by_points((0, height), (width, height))
    l_bottom = line_by_points((0, 0), (width, 0))

    top_intersect = intersection(l1, l_top)
    bot_intersect = intersection(l1, l_bottom)

    left_poings = np.array([[0, 0], [0, height], top_intersect, bot_intersect])
    left_poings[-1][0] += width * buffer_perc
    left_poings[-2][0] += width * buffer_perc

    right_points = np.array([[width, 0], [width, height], top_intersect, bot_intersect])
    right_points[-1][0] -= width * buffer_perc
    right_points[-2][0] -= width * buffer_perc

    crop_and_save(
        img,
        left_poings,
        args.output + "/" + image_path.stem + "a.png",
    )

    crop_and_save(
        img,
        right_points,
        args.output + "/" + image_path.stem + "b.png",
    )


for img_path in tqdm(list(Path(args.input).glob("*.png"))):
    split_middle_line(img_path)
