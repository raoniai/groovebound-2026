#!/usr/bin/env python3
"""Verify release-only invariants in a Groove Bound .love archive."""

from __future__ import annotations

import argparse
import hashlib
import json
import zipfile
from pathlib import Path


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("artifact", type=Path)
    args = parser.parse_args()
    artifact = args.artifact.resolve()

    with zipfile.ZipFile(artifact) as archive:
        bad = archive.testzip()
        names = archive.namelist()
        marker = archive.read("release-build.txt").decode("utf-8") \
            if "release-build.txt" in names else ""

    forbidden = [
        name for name in names
        if name.startswith(("tests/", "docs/", "design-system/", "scripts/"))
        or name.endswith("-source.png")
        or "/source-candidates/" in f"/{name}"
        or name.endswith(".mp4")
    ]
    marker_fields = dict(
        line.split("=", 1) for line in marker.splitlines() if "=" in line
    )
    errors = []
    if bad:
        errors.append(f"bad archive entry: {bad}")
    if forbidden:
        errors.append("forbidden release entries present")
    if marker_fields.get("profile") != "release":
        errors.append("release marker is missing")
    if marker_fields.get("dirty") != "false":
        errors.append("release payload was built from a dirty game tree")

    print(json.dumps({
        "artifact": str(artifact),
        "bytes": artifact.stat().st_size,
        "sha256": sha256(artifact),
        "entries": len(names),
        "marker": marker_fields,
        "forbidden_entries": forbidden,
        "errors": errors,
    }, indent=2))
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
