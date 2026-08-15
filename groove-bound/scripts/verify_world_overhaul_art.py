#!/usr/bin/env python3
"""Verify v0.9.0 transparent atlases and individual mechanic states."""

from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
CAMPAIGN = ROOT / "assets" / "generated" / "campaign"
WORLDS = ("funk", "soul", "disco", "jazz")


def verify_alpha(path: Path, *, grid: bool = False) -> tuple[int, int]:
    if not path.is_file():
        raise RuntimeError(f"missing art: {path.relative_to(ROOT)}")
    with Image.open(path) as image:
        if image.mode != "RGBA":
            raise RuntimeError(f"not RGBA: {path.relative_to(ROOT)}")
        alpha = image.getchannel("A")
        minimum, maximum = alpha.getextrema()
        if minimum != 0 or maximum != 255:
            raise RuntimeError(f"invalid alpha range: {path.relative_to(ROOT)}")
        if grid and (image.width % 4 or image.height % 2):
            raise RuntimeError(f"atlas is not a 4x2 grid: {path.relative_to(ROOT)}")
        return image.width, image.height


def main() -> None:
    verified = 0
    for world in WORLDS:
        for suffix in ("mechanic-atlas", "stage2-environment-atlas"):
            verify_alpha(CAMPAIGN / f"{world}-{suffix}.png", grid=True)
            verified += 1
        states = sorted((CAMPAIGN / "world-mechanics" / world).glob("*.png"))
        if len(states) != 8:
            raise RuntimeError(f"expected eight {world} mechanic states")
        for state in states:
            verify_alpha(state)
            verified += 1
    print(f"verified_world_overhaul_images={verified}")


if __name__ == "__main__":
    main()
