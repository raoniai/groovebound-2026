#!/usr/bin/env python3
"""Remove generated desktop distribution output without touching source."""

from pathlib import Path
import shutil


DIST = Path(__file__).resolve().parents[1] / "dist"
if DIST.exists():
    shutil.rmtree(DIST)
