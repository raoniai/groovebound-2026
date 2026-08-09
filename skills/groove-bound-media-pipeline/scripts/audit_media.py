#!/usr/bin/env python3
"""Audit Groove Bound media classification, size, and obvious package risks."""

from __future__ import annotations

import argparse
import json
import struct
from collections import Counter
from pathlib import Path


DEFAULT_ROOT = Path(__file__).resolve().parents[3]
MEDIA_EXTENSIONS = {".png", ".jpg", ".jpeg", ".ogg", ".ogv", ".mp3", ".mp4", ".ttf"}


def png_dimensions(path: Path) -> tuple[int, int] | None:
    try:
        with path.open("rb") as handle:
            header = handle.read(24)
        if header[:8] == b"\x89PNG\r\n\x1a\n":
            return struct.unpack(">II", header[16:24])
    except OSError:
        pass
    return None


def classify(path: Path) -> str:
    value = path.as_posix()
    name = path.name
    if "/source-candidates/" in value or "-source." in name:
        return "generated-source"
    if "/assets/video/runtime/" in value:
        return "runtime-video"
    if "/assets/video/" in value and path.suffix.lower() == ".mp4":
        return "source-video"
    if "/assets/music/" in value or "/assets/legacy/sfx/" in value:
        return "runtime-audio"
    if "/assets/legacy/" in value:
        return "legacy-runtime"
    if "/assets/generated/" in value:
        return "generated-runtime"
    return "other-runtime"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=DEFAULT_ROOT)
    args = parser.parse_args()
    root = args.root.resolve()
    asset_root = root / "groove-bound" / "assets"
    files = [p for p in asset_root.rglob("*") if p.is_file() and p.suffix.lower() in MEDIA_EXTENSIONS]
    classes = Counter(classify(p) for p in files)
    extensions = Counter(p.suffix.lower() for p in files)
    pngs = []
    for path in files:
        dims = png_dimensions(path)
        if dims:
            pngs.append({"path": str(path.relative_to(root)), "width": dims[0], "height": dims[1]})
    risks = []
    if not (asset_root / "generated" / "PROVENANCE.md").exists():
        risks.append("missing generated provenance")
    if not (asset_root / "legacy" / "PROVENANCE.md").exists():
        risks.append("missing legacy provenance")
    wrong_runtime_video = [str(p.relative_to(root)) for p in files if "/runtime/" in p.as_posix() and p.suffix.lower() == ".mp4"]
    if wrong_runtime_video:
        risks.append("MP4 present in runtime video directory")
    payload = {
        "asset_root": str(asset_root),
        "files": len(files),
        "bytes": sum(p.stat().st_size for p in files),
        "classes": dict(sorted(classes.items())),
        "extensions": dict(sorted(extensions.items())),
        "pngs": pngs,
        "risks": risks,
    }
    print(json.dumps(payload, indent=2))
    return 1 if risks else 0


if __name__ == "__main__":
    raise SystemExit(main())
