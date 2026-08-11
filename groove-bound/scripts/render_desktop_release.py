#!/usr/bin/env python3
"""Verify cross-platform payload parity and render desktop release metadata."""

from __future__ import annotations

import argparse
import hashlib
import json
import zipfile
from pathlib import Path


REQUIRED_ASSETS = (
    "Groove-Bound-Windows-x64.zip",
    "Groove-Bound-macOS.dmg",
    "Groove-Bound-macOS.zip",
    "groove-bound.love",
    "Groove-Bound-Windows-x64.manifest.json",
    "SHA256SUMS-Windows.txt",
)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def find_asset(root: Path, name: str) -> Path:
    matches = list(root.rglob(name))
    if len(matches) != 1:
        raise SystemExit(f"expected one {name}, found {len(matches)}")
    return matches[0]


def release_marker(love_file: Path) -> dict[str, str]:
    with zipfile.ZipFile(love_file) as archive:
        marker = archive.read("release-build.txt").decode("utf-8")
    return dict(line.split("=", 1) for line in marker.splitlines() if "=" in line)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--version", required=True)
    parser.add_argument("--commit", required=True)
    parser.add_argument("--assets-dir", type=Path, required=True)
    parser.add_argument("--template", type=Path, required=True)
    parser.add_argument("--notes-output", type=Path, required=True)
    parser.add_argument("--sums-output", type=Path, required=True)
    args = parser.parse_args()

    assets = {name: find_asset(args.assets_dir, name) for name in REQUIRED_ASSETS}
    hashes = {name: sha256(path) for name, path in assets.items()}
    manifest = json.loads(
        assets["Groove-Bound-Windows-x64.manifest.json"].read_text(encoding="utf-8")
    )
    marker = release_marker(assets["groove-bound.love"])
    commit = args.commit.lower()

    errors = []
    if manifest.get("version") != args.version:
        errors.append("Windows manifest version does not match the release")
    if manifest.get("love_payload", {}).get("sha256") != hashes["groove-bound.love"]:
        errors.append("Windows and Mac artifacts do not share the same .love payload")
    if manifest.get("executable", {}).get("branding") != "icon_and_version_metadata":
        errors.append("Windows executable branding was not verified")
    if manifest.get("executable", {}).get("signing") != "unsigned":
        errors.append("Windows executable signing state is unexpected")
    if marker.get("version") != args.version or marker.get("profile") != "release":
        errors.append("common payload release marker is invalid")
    if marker.get("dirty") != "false":
        errors.append("common payload was built from a dirty game tree")
    if not commit.startswith(marker.get("commit", "missing")):
        errors.append("common payload commit does not match the publishing commit")
    if errors:
        raise SystemExit("; ".join(errors))

    replacements = {
        "{{COMMIT}}": commit,
        "{{WINDOWS_SHA256}}": hashes["Groove-Bound-Windows-x64.zip"],
        "{{MAC_DMG_SHA256}}": hashes["Groove-Bound-macOS.dmg"],
        "{{MAC_ZIP_SHA256}}": hashes["Groove-Bound-macOS.zip"],
        "{{LOVE_SHA256}}": hashes["groove-bound.love"],
        "{{WINDOWS_MANIFEST_SHA256}}": hashes["Groove-Bound-Windows-x64.manifest.json"],
        "{{WINDOWS_SUMS_SHA256}}": hashes["SHA256SUMS-Windows.txt"],
    }
    notes = args.template.read_text(encoding="utf-8")
    for placeholder, value in replacements.items():
        notes = notes.replace(placeholder, value)
    unresolved = [value for value in replacements if value in notes]
    if unresolved:
        raise SystemExit(f"unresolved release-note placeholders: {unresolved}")

    args.notes_output.parent.mkdir(parents=True, exist_ok=True)
    args.notes_output.write_text(notes, encoding="utf-8")
    sums = "\n".join(f"{hashes[name]}  {name}" for name in REQUIRED_ASSETS) + "\n"
    args.sums_output.write_text(sums, encoding="utf-8")
    print(json.dumps({"commit": commit, "marker": marker, "hashes": hashes}, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
