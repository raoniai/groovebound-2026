#!/usr/bin/env python3
"""Generate the Windows multi-resolution icon from canonical app art."""

from pathlib import Path
from PIL import Image


GAME_ROOT = Path(__file__).resolve().parents[1]
SOURCE = GAME_ROOT / "assets/generated/campaign/app-icon.png"
OUTPUT = GAME_ROOT / "packaging/windows/GrooveBound.ico"
OUTPUT.parent.mkdir(parents=True, exist_ok=True)

with Image.open(SOURCE) as image:
    image.convert("RGBA").save(
        OUTPUT,
        format="ICO",
        sizes=[(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)],
    )
print(OUTPUT)
