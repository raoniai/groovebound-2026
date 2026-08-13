#!/usr/bin/env python3
"""Build Groove Bound's deterministic public .love payload."""

from __future__ import annotations

import argparse
import hashlib
import os
import subprocess
import zipfile
from pathlib import Path, PurePosixPath


GAME_ROOT = Path(__file__).resolve().parents[1]
FIXED_ZIP_TIME = (1980, 1, 1, 0, 0, 0)


def git(*args: str) -> str:
    result = subprocess.run(
        ("git", *args), cwd=GAME_ROOT, text=True, capture_output=True, check=False
    )
    return result.stdout.strip() if result.returncode == 0 else "unknown"


def excluded(relative: PurePosixPath) -> bool:
    parts = relative.parts
    if not parts:
        return True
    if parts[0] in {
        "dist", "tests", "docs", "design-system", "scripts", "packaging", "music"
    }:
        return True
    if relative.name in {"Makefile", ".luacheckrc", ".DS_Store"}:
        return True
    if relative.suffix.lower() == ".md" or relative.name.endswith("-source.png"):
        return True
    joined = relative.as_posix()
    if "/source-candidates/" in f"/{joined}":
        return True
    if joined.startswith("assets/generated/campaign/world-tour-sprites/"):
        return True
    if joined.startswith("assets/video/") and relative.suffix.lower() == ".mp4":
        return True
    return False


def archive_info(name: str, executable: bool = False) -> zipfile.ZipInfo:
    info = zipfile.ZipInfo(name, FIXED_ZIP_TIME)
    info.compress_type = zipfile.ZIP_DEFLATED
    mode = 0o755 if executable else 0o644
    info.external_attr = mode << 16
    info.create_system = 3
    return info


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path, default=GAME_ROOT / "dist/groove-bound.love")
    parser.add_argument("--version", default=os.environ.get("VERSION", "0.8.1"))
    parser.add_argument("--require-clean", action="store_true")
    args = parser.parse_args()

    status = git("status", "--porcelain=v1", "--", ".")
    if args.require_clean and status:
        raise SystemExit("public package requires a clean groove-bound/ checkout")

    output = args.output.resolve()
    output.parent.mkdir(parents=True, exist_ok=True)
    if output.exists():
        output.unlink()

    files = []
    for path in GAME_ROOT.rglob("*"):
        if not path.is_file() or path.resolve() == output:
            continue
        relative = PurePosixPath(path.relative_to(GAME_ROOT).as_posix())
        if not excluded(relative):
            files.append((relative, path))
    files.sort(key=lambda item: item[0].as_posix())

    marker = (
        "profile=release\n"
        f"version={args.version}\n"
        f"commit={git('rev-parse', '--short=12', 'HEAD')}\n"
        f"dirty={'true' if status else 'false'}\n"
    ).encode("utf-8")

    with zipfile.ZipFile(output, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
        archive.writestr(archive_info("release-build.txt"), marker)
        for relative, path in files:
            archive.writestr(archive_info(relative.as_posix()), path.read_bytes())

    with zipfile.ZipFile(output) as archive:
        bad = archive.testzip()
        if bad:
            raise SystemExit(f"archive integrity failed at {bad}")

    print(f"built={output}")
    print(f"entries={len(files) + 1}")
    print(f"sha256={sha256(output)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
