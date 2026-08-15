#!/usr/bin/env python3
"""Extract 32 independent five-stage projectile atlases from approved boards."""

from __future__ import annotations

import argparse
import hashlib
from pathlib import Path

from PIL import Image


BOARD_ROWS = {
    "stage-board-base-a-transparent.png": (
        "kazoo_pistol", "bass_drop", "cymbal_slicer", "feedback_loop",
        "drum_circle", "trumpet_burst", "vinyl_scratch", "synth_wave",
    ),
    "stage-board-base-b-transparent.png": (
        "triangle_tracer", "cello_lance", "maraca_orbit", "tuning_fork",
        "keytar_chord", "bell_tower", "tape_repeater", "laser_harp",
    ),
    "stage-board-evolved-a-transparent.png": (
        "brass_barrage", "improvised_solo", "subwoofer_supernova",
        "orbital_ovation", "thunderhead_ensemble", "golden_fortissimo",
        "gravity_groove", "neon_crescendo",
    ),
    "stage-board-evolved-b-transparent.png": (
        "prismatic_triangle", "velvet_impaler", "carnival_superorbit",
        "resonance_rupture", "stadium_keytar", "cathedral_overdrive",
        "infinite_mixtape", "aurora_harp",
    ),
}

FRAME_W = 384
FRAME_H = 128
STAGES = 5
ROWS = 8


def clear_hidden_rgb(image: Image.Image) -> Image.Image:
    pixels = image.load()
    for y in range(image.height):
        for x in range(image.width):
            red, green, blue, alpha = pixels[x, y]
            if alpha == 0:
                pixels[x, y] = (0, 0, 0, 0)
    return image


def fit_cell(cell: Image.Image) -> Image.Image:
    """Fit the complete authored cell, preserving relative size and aspect."""
    scale = min(FRAME_W / cell.width, FRAME_H / cell.height)
    width = max(1, round(cell.width * scale))
    height = max(1, round(cell.height * scale))
    resized = cell.resize((width, height), Image.Resampling.LANCZOS)
    frame = Image.new("RGBA", (FRAME_W, FRAME_H), (0, 0, 0, 0))
    frame.alpha_composite(resized, ((FRAME_W - width) // 2, (FRAME_H - height) // 2))
    return clear_hidden_rgb(frame)


def authored_row_bounds(board: Image.Image) -> list[tuple[int, int]]:
    """Find eight authored lane centres, then split between the centres."""
    alpha = board.getchannel("A")
    weights = []
    for y in range(board.height):
        visible = sum(1 for value in alpha.crop((0, y, board.width, y + 1)).getdata()
                      if value > 32)
        weights.append(visible)
    centers = [(index + 0.5) * board.height / ROWS for index in range(ROWS)]
    for _ in range(24):
        totals = [0.0] * ROWS
        weighted = [0.0] * ROWS
        for y, value in enumerate(weights):
            if value == 0:
                continue
            nearest = min(range(ROWS), key=lambda index: abs(y - centers[index]))
            totals[nearest] += value
            weighted[nearest] += y * value
        centers = [
            weighted[index] / totals[index] if totals[index] else centers[index]
            for index in range(ROWS)
        ]
        centers.sort()
    boundaries = [0]
    for current, following in zip(centers, centers[1:]):
        boundaries.append(round((current + following) / 2))
    boundaries.append(board.height)
    return [(boundaries[index], boundaries[index + 1]) for index in range(ROWS)]


def cell_at(
    board: Image.Image,
    column: int,
    row_bounds: tuple[int, int],
) -> Image.Image:
    left = round(column * board.width / STAGES)
    right = round((column + 1) * board.width / STAGES)
    top, bottom = row_bounds
    # Image generation can leave a few sparks over an intended cell edge.
    # Trim a small gutter so each runtime atlas remains visually independent.
    gutter = max(2, round((right - left) * 0.05))
    left += gutter
    right -= gutter
    return board.crop((left, top, right, bottom))


def build(source_dir: Path, output_dir: Path) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    atlas_digests: set[str] = set()
    built = 0

    for board_name, attack_ids in BOARD_ROWS.items():
        board_path = source_dir / board_name
        board = Image.open(board_path).convert("RGBA")
        row_bounds = authored_row_bounds(board)
        for row, attack_id in enumerate(attack_ids):
            frames = [
                fit_cell(cell_at(board, column, row_bounds[row]))
                for column in range(STAGES)
            ]
            frame_digests = {
                hashlib.sha256(frame.tobytes()).hexdigest() for frame in frames
            }
            if len(frame_digests) != STAGES:
                raise ValueError(f"{attack_id} does not contain five unique stages")
            for index, frame in enumerate(frames, start=1):
                if frame.getchannel("A").getbbox() is None:
                    raise ValueError(f"{attack_id} stage {index} is empty")

            atlas = Image.new("RGBA", (FRAME_W * STAGES, FRAME_H), (0, 0, 0, 0))
            for index, frame in enumerate(frames):
                atlas.alpha_composite(frame, (index * FRAME_W, 0))
            atlas = clear_hidden_rgb(atlas)
            output_path = output_dir / f"{attack_id}.png"
            atlas.save(output_path, optimize=True)
            digest = hashlib.sha256(output_path.read_bytes()).hexdigest()
            if digest in atlas_digests:
                raise ValueError(f"duplicate atlas output for {attack_id}")
            atlas_digests.add(digest)
            built += 1
            print(f"{attack_id}\t{atlas.width}x{atlas.height}\t5 unique stages\t{digest}")

    if built != 32:
        raise ValueError(f"expected 32 atlases, built {built}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source-dir", type=Path, required=True)
    parser.add_argument("--out-dir", type=Path, required=True)
    args = parser.parse_args()
    build(args.source_dir, args.out_dir)


if __name__ == "__main__":
    main()
