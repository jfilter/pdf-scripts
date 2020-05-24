import argparse
from pathlib import Path

parser = argparse.ArgumentParser(
    description="prepend files with index of files"
)
parser.add_argument("directory", type=str, help="path to directory")

args = parser.parse_args()

p = Path(args.directory)

all_paths = [x for x in p.iterdir() if not x.name.startswith('.')]

# add one more digit to be future-proof
num_digits = len(str(len(all_paths))) + 1

for idx, f in enumerate(all_paths):
    new_name = list(f.parts)
    new_name[-1] = str(idx + 1).zfill(num_digits) + '_' + new_name[-1]
    f.rename(Path(*new_name))