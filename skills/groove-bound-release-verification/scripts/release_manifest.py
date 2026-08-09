#!/usr/bin/env python3
"""Describe a Groove Bound .love artifact without mutating the repository."""

from __future__ import annotations

import argparse
import hashlib
import json
import subprocess
import zipfile
from pathlib import Path


DEFAULT_ROOT = Path(__file__).resolve().parents[3]


def git(root: Path, *args: str) -> str:
    result = subprocess.run(("git", *args), cwd=root, text=True, capture_output=True, check=False)
    return result.stdout.strip() if result.returncode == 0 else ""


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=DEFAULT_ROOT)
    parser.add_argument("--artifact", type=Path)
    args = parser.parse_args()
    root = args.root.resolve()
    artifact = (args.artifact or root / "groove-bound" / "dist" / "groove-bound.love").resolve()
    if not artifact.is_file():
        print(json.dumps({"artifact": str(artifact), "error": "artifact not found"}, indent=2))
        return 1
    try:
        with zipfile.ZipFile(artifact) as archive:
            bad = archive.testzip()
            names = archive.namelist()
    except zipfile.BadZipFile:
        print(json.dumps({"artifact": str(artifact), "error": "invalid zip"}, indent=2))
        return 1
    forbidden = [name for name in names if name.startswith(("tests/", "docs/", "design-system/", "scripts/")) or name.endswith("-source.png") or "/source-candidates/" in name or name.endswith(".mp4")]
    repo_status = git(root, "status", "--porcelain=v1", "--untracked-files=all").splitlines()
    game_status = git(root, "status", "--porcelain=v1", "--untracked-files=all", "--", "groove-bound").splitlines()
    payload = {
        "artifact": str(artifact),
        "bytes": artifact.stat().st_size,
        "sha256": sha256(artifact),
        "zip_entries": len(names),
        "zip_integrity": "ok" if bad is None else f"bad entry: {bad}",
        "forbidden_entries": forbidden,
        "branch": git(root, "branch", "--show-current"),
        "commit": git(root, "rev-parse", "--short", "HEAD"),
        "repo_dirty": bool(repo_status),
        "repo_working_changes": len(repo_status),
        "game_dirty": bool(game_status),
        "game_working_changes": len(game_status),
    }
    print(json.dumps(payload, indent=2))
    return 1 if bad or forbidden else 0


if __name__ == "__main__":
    raise SystemExit(main())
