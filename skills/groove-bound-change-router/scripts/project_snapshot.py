#!/usr/bin/env python3
"""Print a read-only Groove Bound repository snapshot as JSON."""

from __future__ import annotations

import argparse
import json
import subprocess
from pathlib import Path


DEFAULT_ROOT = Path(__file__).resolve().parents[3]


def run(root: Path, *args: str) -> str:
    result = subprocess.run(args, cwd=root, text=True, capture_output=True, check=False)
    return result.stdout.strip() if result.returncode == 0 else ""


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=DEFAULT_ROOT)
    args = parser.parse_args()
    root = args.root.resolve()
    status = run(root, "git", "status", "--porcelain=v1", "--untracked-files=all").splitlines()
    game_status = run(root, "git", "status", "--porcelain=v1", "--untracked-files=all", "--", "groove-bound").splitlines()
    site_status = run(root, "git", "status", "--porcelain=v1", "--untracked-files=all", "--", "landing-page").splitlines()
    source_files = list((root / "groove-bound" / "src").rglob("*.lua"))
    test_files = list((root / "groove-bound" / "tests").rglob("*.lua"))
    payload = {
        "root": str(root),
        "branch": run(root, "git", "branch", "--show-current"),
        "head": run(root, "git", "rev-parse", "--short", "HEAD"),
        "head_subject": run(root, "git", "log", "-1", "--pretty=%s"),
        "origin": run(root, "git", "remote", "get-url", "origin"),
        "upstream": run(root, "git", "rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{upstream}"),
        "working_changes": len(status),
        "game_working_changes": len(game_status),
        "site_working_changes": len(site_status),
        "modified": sum(1 for line in status if "M" in line[:2]),
        "untracked": sum(1 for line in status if line.startswith("??")),
        "lua_source_files": len(source_files),
        "lua_test_files": len(test_files),
        "handover_exists": (root / "LATEST_VERSION_HANDOVER.md").exists(),
        "skill_packages": len(list((root / "skills").glob("groove-bound-*/SKILL.md"))),
        "changes": status,
    }
    print(json.dumps(payload, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
