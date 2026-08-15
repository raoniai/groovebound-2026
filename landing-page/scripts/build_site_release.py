#!/usr/bin/env python3
"""Build a clean, hashed Groove Bound static-site release directory."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import shutil
import tempfile
from datetime import datetime, timezone
from pathlib import Path
from urllib.parse import urlsplit


ROOT = Path(__file__).resolve().parents[1]
CORE_FILES = (
    "index.html",
    "catalog.html",
    "builder.html",
    "styles.css",
    "script.js",
    "status-data.js",
)
PUBLIC_EXTENSIONS = {
    ".png",
    ".jpg",
    ".jpeg",
    ".svg",
    ".ttf",
    ".woff",
    ".woff2",
    ".mp4",
    ".webm",
    ".ogg",
}
FORBIDDEN_PARTS = {"source-candidates", "research", "scripts", "__pycache__", ".deployment"}
FORBIDDEN_SUFFIXES = {".psd", ".py", ".pyc", ".md", ".json", ".love", ".zip"}
RELEASE_PATTERN = re.compile(r"^v\d+\.\d+\.\d+$")
HTML_REFERENCE_PATTERN = re.compile(r"(?:src|href|poster)=[\"']([^\"']+)[\"']", re.I)
CSS_REFERENCE_PATTERN = re.compile(r"url\([\"']?([^\"')]+)", re.I)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def public_source_files() -> list[Path]:
    files: list[Path] = []
    for relative in CORE_FILES:
        path = ROOT / relative
        if not path.is_file():
            raise RuntimeError(f"Missing required public file: {relative}")
        files.append(path)
    asset_root = ROOT / "assets"
    for path in sorted(asset_root.rglob("*")):
        if path.is_symlink():
            raise RuntimeError(f"Symlinks are not allowed in a site release: {path.relative_to(ROOT)}")
        if not path.is_file():
            continue
        relative = path.relative_to(ROOT)
        if any(part in FORBIDDEN_PARTS for part in relative.parts):
            continue
        if path.name == ".DS_Store" or "-source" in path.stem.lower():
            continue
        if path.suffix.lower() in PUBLIC_EXTENSIONS:
            files.append(path)
    return sorted(set(files), key=lambda item: item.relative_to(ROOT).as_posix())


def _local_reference(value: str) -> str | None:
    clean = value.strip()
    if not clean or clean.startswith(("#", "%23", "data:", "mailto:", "tel:", "javascript:")):
        return None
    parsed = urlsplit(clean)
    if parsed.scheme or parsed.netloc:
        return None
    return parsed.path or None


def validate_references(public_relatives: set[str]) -> None:
    missing: list[str] = []
    for relative in (*CORE_FILES[:3], "styles.css"):
        path = ROOT / relative
        text = path.read_text(encoding="utf-8")
        pattern = CSS_REFERENCE_PATTERN if path.suffix == ".css" else HTML_REFERENCE_PATTERN
        for match in pattern.finditer(text):
            reference = _local_reference(match.group(1))
            if not reference:
                continue
            resolved = (path.parent / reference).resolve()
            try:
                target = resolved.relative_to(ROOT).as_posix()
            except ValueError:
                missing.append(f"{relative}: reference escapes site root: {reference}")
                continue
            if target not in public_relatives:
                missing.append(f"{relative}: {reference}")
    if missing:
        raise RuntimeError("Missing or excluded public references:\n" + "\n".join(sorted(missing)))


def validate_release_tree(output: Path, expected: set[str]) -> None:
    actual = {
        path.relative_to(output).as_posix()
        for path in output.rglob("*")
        if path.is_file() and path.name != "site-manifest.json"
    }
    if actual != expected:
        missing = sorted(expected - actual)
        unexpected = sorted(actual - expected)
        raise RuntimeError(f"Release tree mismatch; missing={missing}, unexpected={unexpected}")
    forbidden = [
        relative
        for relative in actual
        if any(part in FORBIDDEN_PARTS for part in Path(relative).parts)
        or Path(relative).suffix.lower() in FORBIDDEN_SUFFIXES
        or Path(relative).name == ".DS_Store"
    ]
    if forbidden:
        raise RuntimeError("Forbidden files entered the release: " + ", ".join(sorted(forbidden)))


def build_release(release: str, output: Path) -> dict[str, object]:
    if not RELEASE_PATTERN.fullmatch(release):
        raise RuntimeError(f"Release must look like v0.8.0, got: {release}")
    if output.exists() and any(output.iterdir()):
        raise RuntimeError(f"Output directory must be empty: {output}")
    output.mkdir(parents=True, exist_ok=True)
    sources = public_source_files()
    relatives = {path.relative_to(ROOT).as_posix() for path in sources}
    validate_references(relatives)
    for source in sources:
        destination = output / source.relative_to(ROOT)
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, destination)
    validate_release_tree(output, relatives)
    files = []
    for relative in sorted(relatives):
        path = output / relative
        files.append({"path": relative, "bytes": path.stat().st_size, "sha256": sha256(path)})
    manifest: dict[str, object] = {
        "release": release,
        "generated_at": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "file_count": len(files),
        "total_bytes": sum(int(item["bytes"]) for item in files),
        "files": files,
    }
    (output / "site-manifest.json").write_text(
        json.dumps(manifest, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )
    return manifest


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--release", required=True, help="Release label, for example v0.8.0")
    parser.add_argument("--output", type=Path, help="Empty output directory; defaults to a new temp directory")
    args = parser.parse_args()
    output = args.output or Path(tempfile.mkdtemp(prefix=f"groove-bound-site-{args.release}-"))
    manifest = build_release(args.release, output)
    print(f"release directory: {output}")
    print(f"public files: {manifest['file_count']}")
    print(f"public bytes: {manifest['total_bytes']}")
    print(f"manifest: {output / 'site-manifest.json'}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"build error: {exc}")
        raise SystemExit(1)
