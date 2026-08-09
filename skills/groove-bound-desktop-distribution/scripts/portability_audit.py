#!/usr/bin/env python3
"""Find cross-platform filename hazards in the Groove Bound runtime tree."""

from __future__ import annotations

import argparse
import json
from collections import defaultdict
from pathlib import Path


DEFAULT_ROOT = Path(__file__).resolve().parents[3]
RESERVED = {"con", "prn", "aux", "nul", *(f"com{i}" for i in range(1, 10)), *(f"lpt{i}" for i in range(1, 10))}
INVALID = set('<>:"\\|?*')


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=DEFAULT_ROOT)
    args = parser.parse_args()
    root = args.root.resolve()
    runtime = root / "groove-bound"
    paths = [p for p in runtime.rglob("*") if "dist" not in p.parts]
    folded: dict[str, list[str]] = defaultdict(list)
    reserved = []
    invalid = []
    trailing = []
    long_paths = []
    for path in paths:
        rel = path.relative_to(runtime).as_posix()
        folded[rel.casefold()].append(rel)
        for part in path.relative_to(runtime).parts:
            stem = part.split(".", 1)[0].casefold()
            if stem in RESERVED:
                reserved.append(rel)
            if any(char in INVALID for char in part):
                invalid.append(rel)
            if part.endswith((" ", ".")):
                trailing.append(rel)
        if len(str(path)) > 240:
            long_paths.append(rel)
    collisions = [items for items in folded.values() if len(set(items)) > 1]
    payload = {
        "runtime": str(runtime),
        "paths_scanned": len(paths),
        "case_collisions": collisions,
        "windows_reserved": sorted(set(reserved)),
        "invalid_characters": sorted(set(invalid)),
        "trailing_space_or_dot": sorted(set(trailing)),
        "paths_over_240_chars": sorted(set(long_paths)),
    }
    print(json.dumps(payload, indent=2))
    return 1 if collisions or reserved or invalid or trailing else 0


if __name__ == "__main__":
    raise SystemExit(main())
