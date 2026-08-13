#!/usr/bin/env python3
"""Normalize the generated HUD badge and segmented-bar sprite kit."""

import argparse
from pathlib import Path

from PIL import Image


COLUMNS = 3
ROWS = 2


def clear_hidden_rgb(image: Image.Image) -> Image.Image:
    result = Image.new("RGBA", image.size)
    result.putdata([
        (red, green, blue, alpha) if alpha else (0, 0, 0, 0)
        for red, green, blue, alpha in image.convert("RGBA").getdata()
    ])
    return result


def cell(source: Image.Image, column: int, row: int) -> Image.Image:
    width, height = source.size
    left = round(column * width / COLUMNS)
    top = round(row * height / ROWS)
    right = round((column + 1) * width / COLUMNS)
    bottom = round((row + 1) * height / ROWS)
    value = clear_hidden_rgb(source.crop((left, top, right, bottom)))
    bounds = value.getchannel("A").getbbox()
    if not bounds:
        raise SystemExit(f"empty source cell at row {row + 1}, column {column + 1}")
    return value.crop(bounds)


def fit_square(value: Image.Image, size: int = 256, inset: int = 20) -> Image.Image:
    span = size - inset * 2
    scale = min(span / value.width, span / value.height)
    resized = value.resize(
        (max(1, round(value.width * scale)), max(1, round(value.height * scale))),
        Image.Resampling.NEAREST,
    )
    output = Image.new("RGBA", (size, size))
    output.alpha_composite(resized, ((size - resized.width) // 2, (size - resized.height) // 2))
    return clear_hidden_rgb(output)


def horizontal_piece(value: Image.Image, side: str, output_size: tuple[int, int]) -> Image.Image:
    """Take a stable cap or repeatable rail sample from a generated bar."""
    width, height = value.size
    if side == "left":
        crop = value.crop((0, 0, min(width, round(height * 1.45)), height))
    elif side == "right":
        crop = value.crop((max(0, width - round(height * 1.45)), 0, width, height))
    else:
        sample_width = min(width, max(12, round(height * 0.72)))
        centre = width // 2
        crop = value.crop((centre - sample_width // 2, 0, centre + (sample_width + 1) // 2, height))
    return clear_hidden_rgb(crop.resize(output_size, Image.Resampling.NEAREST))


def fill_piece(value: Image.Image) -> Image.Image:
    """Keep only the pale segmented interior, excluding its decorative rails."""
    width, height = value.size
    centre = width // 2
    sample_width = min(width, max(12, round(height * 0.72)))
    crop = value.crop((
        centre - sample_width // 2,
        round(height * 0.24),
        centre + (sample_width + 1) // 2,
        round(height * 0.76),
    ))
    return clear_hidden_rgb(crop.resize((64, 24), Image.Resampling.NEAREST))


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--output-root", type=Path, required=True)
    args = parser.parse_args()

    source = Image.open(args.source).convert("RGBA")
    args.output_root.mkdir(parents=True, exist_ok=True)

    fit_square(cell(source, 0, 0)).save(args.output_root / "rank-badge.png", optimize=True)
    fit_square(cell(source, 1, 0)).save(args.output_root / "max-badge.png", optimize=True)

    left_source = cell(source, 2, 0)
    middle_source = cell(source, 0, 1)
    right_source = cell(source, 1, 1)
    fill_source = cell(source, 2, 1)
    horizontal_piece(left_source, "left", (96, 64)).save(
        args.output_root / "bar-left.png", optimize=True)
    horizontal_piece(middle_source, "middle", (64, 64)).save(
        args.output_root / "bar-middle.png", optimize=True)
    horizontal_piece(right_source, "right", (96, 64)).save(
        args.output_root / "bar-right.png", optimize=True)
    fill_piece(fill_source).save(
        args.output_root / "bar-fill.png", optimize=True)

    expected = {
        "rank-badge.png": (256, 256),
        "max-badge.png": (256, 256),
        "bar-left.png": (96, 64),
        "bar-middle.png": (64, 64),
        "bar-right.png": (96, 64),
        "bar-fill.png": (64, 24),
    }
    for name, dimensions in expected.items():
        value = Image.open(args.output_root / name)
        if value.mode != "RGBA" or value.size != dimensions:
            raise SystemExit(f"invalid runtime sprite {name}: {value.mode} {value.size}")
        if not value.getchannel("A").getbbox():
            raise SystemExit(f"runtime sprite is empty: {name}")


if __name__ == "__main__":
    main()
