#!/usr/bin/env python3
"""Build separate nine-slice runtime sprites from the approved card source."""

import argparse
from pathlib import Path

from PIL import Image


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True)
    parser.add_argument("--out-dir", required=True)
    args = parser.parse_args()

    source = Image.open(args.input).convert("RGBA")
    bounds = source.getchannel("A").getbbox()
    if not bounds:
        raise SystemExit("card frame source has no visible pixels")
    frame = source.crop(bounds)
    width, height = frame.size
    corner = min(192, width // 3, height // 3)
    xs = (0, corner, width - corner, width)
    ys = (0, corner, height - corner, height)
    names = (
        ("top-left", "top", "top-right"),
        ("left", "center", "right"),
        ("bottom-left", "bottom", "bottom-right"),
    )

    output = Path(args.out_dir)
    output.mkdir(parents=True, exist_ok=True)
    for row in range(3):
        for column in range(3):
            part = frame.crop((xs[column], ys[row], xs[column + 1], ys[row + 1]))
            part.save(output / f"{names[row][column]}.png", optimize=True)


if __name__ == "__main__":
    main()
