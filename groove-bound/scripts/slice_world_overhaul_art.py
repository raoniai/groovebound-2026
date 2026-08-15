#!/usr/bin/env python3
"""Slice v0.9.0 world-mechanic atlases into individual animation states."""

from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
CAMPAIGN = ROOT / "assets" / "generated" / "campaign"
STATE_NAMES = (
    "dormant",
    "cue",
    "build-a",
    "build-b",
    "success",
    "relay",
    "encore",
    "cooldown",
)


def normalize_atlas(path: Path) -> None:
    with Image.open(path) as atlas:
        width = atlas.width - atlas.width % 4
        height = atlas.height - atlas.height % 2
        if (width, height) != atlas.size:
            atlas.crop((0, 0, width, height)).save(path)


def slice_atlas(world: str) -> None:
    source = CAMPAIGN / f"{world}-mechanic-atlas.png"
    normalize_atlas(source)
    destination = CAMPAIGN / "world-mechanics" / world
    destination.mkdir(parents=True, exist_ok=True)
    with Image.open(source) as atlas:
        cell_width = atlas.width // 4
        cell_height = atlas.height // 2
        for index, name in enumerate(STATE_NAMES):
            column = index % 4
            row = index // 4
            box = (
                column * cell_width,
                row * cell_height,
                (column + 1) * cell_width,
                (row + 1) * cell_height,
            )
            atlas.crop(box).save(destination / f"{index + 1:02d}-{name}.png")


def main() -> None:
    for world in ("funk", "soul", "disco", "jazz"):
        normalize_atlas(CAMPAIGN / f"{world}-stage2-environment-atlas.png")
        slice_atlas(world)


if __name__ == "__main__":
    main()
