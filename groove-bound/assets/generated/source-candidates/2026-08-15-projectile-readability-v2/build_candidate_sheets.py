#!/usr/bin/env python3
"""Normalize generated 4x2 projectile boards into exact candidate sheets.

This script is source-candidate tooling only. It does not write to the runtime
projectile directory and deliberately refuses to upscale generated artwork.
"""

from __future__ import annotations

import hashlib
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parent
INPUT_DIR = ROOT / "keyed-sheets"
OUTPUT_DIR = ROOT / "sheets"
COLS = 4
ROWS = 2
CELL = 512
SAFE = 448
ALPHA_THRESHOLD = 8


def visible_bbox(image: Image.Image) -> tuple[int, int, int, int] | None:
    alpha = image.getchannel("A").point(
        lambda value: 255 if value > ALPHA_THRESHOLD else 0
    )
    return alpha.getbbox()


def clear_hidden_rgb(image: Image.Image) -> Image.Image:
    pixels = image.load()
    for y in range(image.height):
        for x in range(image.width):
            red, green, blue, alpha = pixels[x, y]
            if alpha == 0:
                pixels[x, y] = (0, 0, 0, 0)
    return image


def normalize_frame(frame: Image.Image) -> Image.Image:
    bbox = visible_bbox(frame)
    if bbox is None:
        raise ValueError("empty animation frame")

    left, top, right, bottom = bbox
    pad = 4
    left = max(0, left - pad)
    top = max(0, top - pad)
    right = min(frame.width, right + pad)
    bottom = min(frame.height, bottom + pad)
    art = frame.crop((left, top, right, bottom))

    # Preserve authored proportions and never enlarge generated pixels.
    scale = min(1.0, SAFE / art.width, SAFE / art.height)
    if scale < 1.0:
        art = art.resize(
            (max(1, round(art.width * scale)), max(1, round(art.height * scale))),
            Image.Resampling.LANCZOS,
        )

    target = Image.new("RGBA", (CELL, CELL), (0, 0, 0, 0))
    target.alpha_composite(
        art,
        ((CELL - art.width) // 2, (CELL - art.height) // 2),
    )
    return clear_hidden_rgb(target)


def split_frames(board: Image.Image) -> list[Image.Image]:
    frames: list[Image.Image] = []
    for row in range(ROWS):
        top = round(row * board.height / ROWS)
        bottom = round((row + 1) * board.height / ROWS)
        for col in range(COLS):
            left = round(col * board.width / COLS)
            right = round((col + 1) * board.width / COLS)
            frames.append(normalize_frame(board.crop((left, top, right, bottom))))
    return frames


def build() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    inputs = sorted(INPUT_DIR.glob("*.png"))
    if len(inputs) != 32:
        raise ValueError(f"expected 32 keyed sheets, found {len(inputs)}")

    output_hashes: set[str] = set()
    for source in inputs:
        board = Image.open(source).convert("RGBA")
        frames = split_frames(board)
        if len(frames) != 8:
            raise ValueError(f"{source.name}: expected 8 frames")

        frame_hashes = {hashlib.sha256(frame.tobytes()).hexdigest() for frame in frames}
        if len(frame_hashes) != 8:
            raise ValueError(f"{source.name}: frames are not all distinct")

        sheet = Image.new("RGBA", (COLS * CELL, ROWS * CELL), (0, 0, 0, 0))
        for index, frame in enumerate(frames):
            x = (index % COLS) * CELL
            y = (index // COLS) * CELL
            sheet.alpha_composite(frame, (x, y))
        sheet = clear_hidden_rgb(sheet)

        alpha = sheet.getchannel("A")
        histogram = alpha.histogram()
        pixels = sheet.width * sheet.height
        transparent_pct = 100 * histogram[0] / pixels
        partial_pct = 100 * sum(histogram[1:255]) / pixels
        opaque_pct = 100 * histogram[255] / pixels
        if transparent_pct < 50:
            raise ValueError(f"{source.name}: insufficient transparent area")
        if partial_pct == 0:
            raise ValueError(f"{source.name}: no partial-alpha pixels")

        for index, frame in enumerate(frames, start=1):
            frame_alpha = frame.getchannel("A")
            edge = Image.new("L", frame_alpha.size, 0)
            edge.paste(frame_alpha.crop((0, 0, CELL, 1)), (0, 0))
            edge.paste(frame_alpha.crop((0, CELL - 1, CELL, CELL)), (0, CELL - 1))
            edge.paste(frame_alpha.crop((0, 0, 1, CELL)), (0, 0))
            edge.paste(frame_alpha.crop((CELL - 1, 0, CELL, CELL)), (CELL - 1, 0))
            if edge.getbbox() is not None:
                raise ValueError(f"{source.name}: frame {index} touches cell edge")

        output = OUTPUT_DIR / source.name
        sheet.save(output, optimize=True)
        digest = hashlib.sha256(output.read_bytes()).hexdigest()
        if digest in output_hashes:
            raise ValueError(f"duplicate candidate output: {source.name}")
        output_hashes.add(digest)
        print(
            f"{source.stem}\t2048x1024 RGBA\t8 unique frames\t"
            f"transparent={transparent_pct:.2f}%\tpartial={partial_pct:.2f}%\t"
            f"opaque={opaque_pct:.2f}%\t{digest}"
        )


if __name__ == "__main__":
    build()
