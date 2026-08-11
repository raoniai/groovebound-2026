#!/usr/bin/env python3
"""Key generated menu art and build stable runtime atlas/nine-slice assets."""

import argparse
from pathlib import Path

from PIL import Image


def chroma_key(source: Image.Image) -> Image.Image:
    rgba = source.convert("RGBA")
    cleaned = []
    for red, green, blue, _ in rgba.getdata():
        dominance = green - max(red, blue)
        if green > 105 and dominance > 18:
            key = min(1.0, max(0.0, (dominance - 18) / 105))
            alpha = round(255 * (1 - key))
            green = min(green, max(red, blue) + 18)
        else:
            alpha = 255
        cleaned.append((red, green, blue, alpha) if alpha else (0, 0, 0, 0))
    rgba.putdata(cleaned)
    return rgba


def fit_atlas(source: Image.Image) -> Image.Image:
    """Pad to 4:3 before resizing so all twelve cells remain square."""
    width, height = source.size
    target_ratio = 4 / 3
    if width / height > target_ratio:
        padded_height = round(width / target_ratio)
        canvas = Image.new("RGB", (width, padded_height), (0, 255, 0))
        canvas.paste(source.convert("RGB"), (0, (padded_height - height) // 2))
    else:
        padded_width = round(height * target_ratio)
        canvas = Image.new("RGB", (padded_width, height), (0, 255, 0))
        canvas.paste(source.convert("RGB"), ((padded_width - width) // 2, 0))
    return chroma_key(canvas.resize((1600, 1200), Image.Resampling.LANCZOS))


def build_focus_parts(source: Image.Image, output: Path) -> None:
    keyed = chroma_key(source)
    bounds = keyed.getchannel("A").getbbox()
    if not bounds:
        raise SystemExit("focus frame source has no visible pixels")
    frame = keyed.crop(bounds)
    width, height = frame.size
    corner = min(220, width // 4, height // 3)
    xs = (0, corner, width - corner, width)
    ys = (0, corner, height - corner, height)
    names = (
        ("top-left", "top", "top-right"),
        ("left", "center", "right"),
        ("bottom-left", "bottom", "bottom-right"),
    )
    output.mkdir(parents=True, exist_ok=True)
    for row in range(3):
        for column in range(3):
            frame.crop((xs[column], ys[row], xs[column + 1], ys[row + 1])).save(
                output / f"{names[row][column]}.png", optimize=True)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--atlas-source", type=Path, required=True)
    parser.add_argument("--atlas-output", type=Path, required=True)
    parser.add_argument("--focus-source", type=Path, required=True)
    parser.add_argument("--focus-output", type=Path, required=True)
    args = parser.parse_args()

    atlas = fit_atlas(Image.open(args.atlas_source))
    args.atlas_output.parent.mkdir(parents=True, exist_ok=True)
    atlas.save(args.atlas_output, optimize=True)
    build_focus_parts(Image.open(args.focus_source), args.focus_output)


if __name__ == "__main__":
    main()
