#!/usr/bin/env python3
"""Refresh the generated live snapshot inside LATEST_VERSION_HANDOVER.md."""

from __future__ import annotations

import argparse
import os
import re
import subprocess
import tempfile
from datetime import datetime
from pathlib import Path
from zoneinfo import ZoneInfo


DEFAULT_ROOT = Path(__file__).resolve().parents[3]
START = "<!-- LIVE-SNAPSHOT:START -->"
END = "<!-- LIVE-SNAPSHOT:END -->"


def command(cwd: Path, *args: str) -> tuple[int, str]:
    result = subprocess.run(args, cwd=cwd, text=True, capture_output=True, check=False)
    return result.returncode, (result.stdout + result.stderr).strip()


def git(root: Path, *args: str) -> str:
    code, output = command(root, "git", *args)
    return output.strip() if code == 0 else "unavailable"


def count_status(root: Path, path: str | None = None) -> list[str]:
    args = ["status", "--porcelain=v1", "--untracked-files=all"]
    if path:
        args.extend(("--", path))
    output = git(root, *args)
    return [] if output in {"", "unavailable"} else output.splitlines()


def directory_bytes(path: Path, exclude_top_level: set[str] | None = None) -> int:
    if not path.exists():
        return 0
    excluded = exclude_top_level or set()
    return sum(
        p.stat().st_size
        for p in path.rglob("*")
        if p.is_file() and not (set(p.relative_to(path).parts[:1]) & excluded)
    )


def check_result(game: Path, target: str) -> str:
    code, output = command(game, "make", target)
    if target == "test":
        match = re.search(r"(\d+) tests, (\d+) failures", output)
        detail = f"{match.group(1)} tests, {match.group(2)} failures" if match else "result not parsed"
    else:
        match = re.search(r"Total:\s+([^\n]+)", output)
        detail = match.group(1).strip() if match else "result not parsed"
    return f"passed: {detail}" if code == 0 else f"failed: {detail}"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=DEFAULT_ROOT)
    parser.add_argument("--run-checks", action="store_true")
    args = parser.parse_args()
    root = args.root.resolve()
    handover = root / "LATEST_VERSION_HANDOVER.md"
    if not handover.exists():
        raise SystemExit(f"Missing {handover}")
    text = handover.read_text()
    if START not in text or END not in text:
        raise SystemExit("Handover snapshot markers are missing")

    all_status = count_status(root)
    game_status = count_status(root, "groove-bound")
    site_status = count_status(root, "landing-page")
    skills_status = count_status(root, "skills")
    relation = git(root, "rev-list", "--left-right", "--count", "origin/main...HEAD").split()
    behind, ahead = (relation + ["unavailable", "unavailable"])[:2]
    now = datetime.now(ZoneInfo("Australia/Sydney")).strftime("%Y-%m-%d %H:%M %Z")
    game = root / "groove-bound"
    tests = check_result(game, "test") if args.run_checks else "not run by this refresh"
    lint = check_result(game, "lint") if args.run_checks else "not run by this refresh"
    lines = [
        START,
        "",
        f"_Generated from live repository evidence: {now}_",
        "",
        "| Field | Live value |",
        "|---|---|",
        f"| Branch | `{git(root, 'branch', '--show-current')}` |",
        f"| HEAD | `{git(root, 'rev-parse', '--short', 'HEAD')}` — {git(root, 'log', '-1', '--pretty=%s')} |",
        f"| Upstream | `{git(root, 'rev-parse', '--abbrev-ref', '--symbolic-full-name', '@{upstream}')}` |",
        f"| Compared with `origin/main` | {ahead} ahead, {behind} behind |",
        f"| Working changes | {len(all_status)} files: {len(game_status)} game, {len(site_status)} site, {len(skills_status)} skills/package |",
        f"| Lua source/test files | {len(list((game / 'src').rglob('*.lua')))} source, {len(list((game / 'tests').rglob('*.lua')))} test |",
        f"| Game tree excluding `dist/` | {directory_bytes(game, {'dist'}) / (1024 * 1024):.1f} MiB |",
        f"| Current `.love` artifact | {(game / 'dist' / 'groove-bound.love').stat().st_size / (1024 * 1024):.1f} MiB |" if (game / "dist" / "groove-bound.love").exists() else "| Current `.love` artifact | not present |",
        f"| Test suite | {tests} |",
        f"| Lint | {lint} |",
        f"| Skill packages | {len(list((root / 'skills').glob('groove-bound-*/SKILL.md')))} |",
        "",
        END,
    ]
    replacement = "\n".join(lines)
    updated = re.sub(re.escape(START) + r".*?" + re.escape(END), replacement, text, flags=re.DOTALL)
    with tempfile.NamedTemporaryFile("w", dir=root, delete=False) as handle:
        handle.write(updated)
        temp_name = handle.name
    os.replace(temp_name, handover)
    print(f"Updated {handover}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
