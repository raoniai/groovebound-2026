#!/usr/bin/env python3
"""Build the restrained monochrome CTA and menu/stat runtime asset suite."""

import argparse
import colorsys
from pathlib import Path

from PIL import Image


ATLAS_COLUMNS = 4
ATLAS_ROWS = 4
ATLAS_CELL = 400
SAFE_INSET = 64


def chroma_key(source: Image.Image) -> Image.Image:
    rgba = source.convert("RGBA")
    cleaned = []
    for red, green, blue, _ in rgba.getdata():
        dominance = green - max(red, blue)
        if green > 96 and dominance > 16:
            key = min(1.0, max(0.0, (dominance - 16) / 112))
            alpha = round(255 * (1 - key))
            green = min(green, max(red, blue) + 14)
        else:
            alpha = 255
        cleaned.append((red, green, blue, alpha) if alpha else (0, 0, 0, 0))
    rgba.putdata(cleaned)
    return rgba


def monochrome_cyan(source: Image.Image) -> Image.Image:
    """Lock visible art to one cyan hue while preserving luminance depth."""
    converted = []
    for red, green, blue, alpha in source.getdata():
        if alpha == 0:
            converted.append((0, 0, 0, 0))
            continue
        luminance = (0.2126 * red + 0.7152 * green + 0.0722 * blue) / 255
        if luminance < 0.16:
            value = 0.055 + luminance * 0.55
            saturation = 0.78
        else:
            value = min(1.0, 0.10 + luminance * 1.20)
            saturation = max(0.58, min(0.94, 0.96 - luminance * 0.25))
        out_red, out_green, out_blue = colorsys.hsv_to_rgb(
            0.535, saturation, value)
        converted.append((
            round(out_red * 255), round(out_green * 255),
            round(out_blue * 255), alpha,
        ))
    result = Image.new("RGBA", source.size)
    result.putdata(converted)
    return result


def clear_hidden_rgb(image: Image.Image) -> Image.Image:
    cleaned = Image.new("RGBA", image.size)
    cleaned.putdata([
        (red, green, blue, alpha) if alpha else (0, 0, 0, 0)
        for red, green, blue, alpha in image.getdata()
    ])
    return cleaned


def normalized_atlas(source_path: Path) -> Image.Image:
    source = monochrome_cyan(chroma_key(Image.open(source_path)))
    width, height = source.size
    output = Image.new(
        "RGBA", (ATLAS_COLUMNS * ATLAS_CELL, ATLAS_ROWS * ATLAS_CELL))
    target_span = ATLAS_CELL - SAFE_INSET * 2

    for row in range(ATLAS_ROWS):
        top = round(row * height / ATLAS_ROWS)
        bottom = round((row + 1) * height / ATLAS_ROWS)
        for column in range(ATLAS_COLUMNS):
            left = round(column * width / ATLAS_COLUMNS)
            right = round((column + 1) * width / ATLAS_COLUMNS)
            cell = source.crop((left, top, right, bottom))
            bounds = cell.getchannel("A").getbbox()
            if not bounds:
                raise SystemExit(
                    f"empty generated icon cell at row {row + 1}, column {column + 1}")
            icon = cell.crop(bounds)
            scale = min(target_span / icon.width, target_span / icon.height)
            size = (
                max(1, round(icon.width * scale)),
                max(1, round(icon.height * scale)),
            )
            icon = icon.resize(size, Image.Resampling.NEAREST)
            x = column * ATLAS_CELL + (ATLAS_CELL - icon.width) // 2
            y = row * ATLAS_CELL + (ATLAS_CELL - icon.height) // 2
            output.alpha_composite(icon, (x, y))

    output = clear_hidden_rgb(output)
    for row in range(ATLAS_ROWS):
        for column in range(ATLAS_COLUMNS):
            cell = output.crop((
                column * ATLAS_CELL, row * ATLAS_CELL,
                (column + 1) * ATLAS_CELL, (row + 1) * ATLAS_CELL,
            ))
            bounds = cell.getchannel("A").getbbox()
            if not bounds:
                raise SystemExit("normalised atlas contains an empty cell")
            left, top, right, bottom = bounds
            if min(left, top, ATLAS_CELL - right, ATLAS_CELL - bottom) < SAFE_INSET:
                raise SystemExit("normalised atlas violated its safe inset")
    return output


def focus_outline(frame: Image.Image) -> Image.Image:
    pixels = []
    for red, green, blue, alpha in frame.getdata():
        luminance = (0.2126 * red + 0.7152 * green + 0.0722 * blue) / 255
        if alpha == 0 or luminance < 0.18:
            pixels.append((0, 0, 0, 0))
        else:
            pixels.append((red, green, blue, min(255, round(alpha * 1.15))))
    result = Image.new("RGBA", frame.size)
    result.putdata(pixels)
    return result


def save_nine_slice(frame: Image.Image, output: Path) -> None:
    bounds = frame.getchannel("A").getbbox()
    if not bounds:
        raise SystemExit("CTA frame source has no visible pixels")
    frame = clear_hidden_rgb(frame.crop(bounds))
    width, height = frame.size
    corner = min(round(height * 0.38), width // 5)
    sample = max(8, min(40, corner // 3))
    middle_x = max(corner, min(width - corner - sample, width // 3))
    middle_y = max(corner, min(height - corner - sample, height // 2))
    pieces = {
        "top-left": (0, 0, corner, corner),
        "top": (middle_x, 0, middle_x + sample, corner),
        "top-right": (width - corner, 0, width, corner),
        "left": (0, middle_y, corner, middle_y + sample),
        "center": (middle_x, middle_y, middle_x + sample, middle_y + sample),
        "right": (width - corner, middle_y, width, middle_y + sample),
        "bottom-left": (0, height - corner, corner, height),
        "bottom": (middle_x, height - corner, middle_x + sample, height),
        "bottom-right": (width - corner, height - corner, width, height),
    }
    output.mkdir(parents=True, exist_ok=True)
    for name, box in pieces.items():
        frame.crop(box).save(output / f"{name}.png", optimize=True)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--menu-stat-source", type=Path, required=True)
    parser.add_argument("--settings-source", type=Path, required=True)
    parser.add_argument("--cta-source", type=Path, required=True)
    parser.add_argument("--output-root", type=Path, required=True)
    args = parser.parse_args()

    args.output_root.mkdir(parents=True, exist_ok=True)
    normalized_atlas(args.menu_stat_source).save(
        args.output_root / "menu-stat-icons-v1.png", optimize=True)
    normalized_atlas(args.settings_source).save(
        args.output_root / "settings-icons-v1.png", optimize=True)

    frame = monochrome_cyan(chroma_key(Image.open(args.cta_source)))
    save_nine_slice(frame, args.output_root / "cta-frame-v1")
    save_nine_slice(focus_outline(frame), args.output_root / "cta-focus-v1")


if __name__ == "__main__":
    main()
