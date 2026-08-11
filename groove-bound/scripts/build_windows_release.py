#!/usr/bin/env python3
"""Build Groove Bound's fused, self-contained Windows x64 ZIP."""

from __future__ import annotations

import argparse
import hashlib
import json
import shutil
import subprocess
import zipfile
from pathlib import Path


GAME_ROOT = Path(__file__).resolve().parents[1]
DIST = GAME_ROOT / "dist"
PRODUCT = "Groove Bound"
ZIP_NAME = "Groove-Bound-Windows-x64.zip"
FIXED_ZIP_TIME = (1980, 1, 1, 0, 0, 0)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def copy_streams(destination: Path, *sources: Path) -> None:
    with destination.open("wb") as output:
        for source in sources:
            with source.open("rb") as handle:
                shutil.copyfileobj(handle, output, length=1024 * 1024)


def windows_version(version: str) -> str:
    parts = version.lstrip("v").split(".")
    if not all(part.isdigit() for part in parts) or not 1 <= len(parts) <= 4:
        raise ValueError(f"invalid numeric release version: {version}")
    return ".".join((parts + ["0"] * 4)[:4])


def zip_tree(source: Path, destination: Path) -> None:
    if destination.exists():
        destination.unlink()
    files = sorted(path for path in source.rglob("*") if path.is_file())
    with zipfile.ZipFile(destination, "w", zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
        for path in files:
            relative = Path(PRODUCT) / path.relative_to(source)
            info = zipfile.ZipInfo(relative.as_posix(), FIXED_ZIP_TIME)
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = 0o644 << 16
            archive.writestr(info, path.read_bytes())


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--version", default="0.7.1")
    parser.add_argument("--runtime-dir", type=Path, required=True)
    parser.add_argument("--love-file", type=Path, default=DIST / "groove-bound.love")
    parser.add_argument("--icon", type=Path, default=GAME_ROOT / "packaging/windows/GrooveBound.ico")
    parser.add_argument("--resource-editor", type=Path)
    parser.add_argument("--require-branding", action="store_true")
    args = parser.parse_args()

    runtime = args.runtime_dir.resolve()
    love_file = args.love_file.resolve()
    love_exe = runtime / "love.exe"
    license_file = runtime / "license.txt"
    if not love_exe.is_file() or not license_file.is_file():
        raise SystemExit("runtime must be the extracted official LÖVE x64 ZIP")
    if not love_file.is_file():
        raise SystemExit(f"common payload not found: {love_file}")
    dlls = sorted(runtime.glob("*.dll"))
    if not dlls:
        raise SystemExit("official LÖVE runtime DLLs are missing")
    if args.require_branding and (not args.resource_editor or not args.resource_editor.is_file()):
        raise SystemExit("branded public build requires rcedit")

    stage_root = DIST / "windows-build"
    stage = stage_root / PRODUCT
    if stage_root.exists():
        shutil.rmtree(stage_root)
    shutil.copytree(runtime, stage)

    target_exe = stage / f"{PRODUCT}.exe"
    copy_streams(target_exe, love_exe, love_file)
    for development_exe in (stage / "love.exe", stage / "lovec.exe"):
        if development_exe.exists():
            development_exe.unlink()

    branding = "unbranded"
    if args.resource_editor and args.resource_editor.is_file():
        if not args.icon.is_file():
            raise SystemExit(f"Windows icon is missing: {args.icon}")
        version = windows_version(args.version)
        command = [
            str(args.resource_editor), str(target_exe),
            "--set-icon", str(args.icon),
            "--set-file-version", version,
            "--set-product-version", version,
            "--set-version-string", "ProductName", PRODUCT,
            "--set-version-string", "FileDescription", PRODUCT,
            "--set-version-string", "CompanyName", "Raoni Lima",
            "--set-version-string", "LegalCopyright", "Copyright 2026 Raoni Lima",
            "--set-version-string", "OriginalFilename", f"{PRODUCT}.exe",
        ]
        subprocess.run(command, check=True)
        branding = "icon_and_version_metadata"

    instructions = (GAME_ROOT / "packaging/windows/README-Windows.txt").read_text()
    (stage / "README-Windows.txt").write_text(
        instructions.replace("{{VERSION}}", args.version), encoding="utf-8", newline="\r\n"
    )

    file_records = []
    for path in sorted(item for item in stage.rglob("*") if item.is_file()):
        if path.name == "manifest.json":
            continue
        file_records.append({
            "path": path.relative_to(stage).as_posix(),
            "bytes": path.stat().st_size,
            "sha256": sha256(path),
        })
    manifest = {
        "product": PRODUCT,
        "version": args.version,
        "target": "windows-x64",
        "architecture": "x86_64",
        "love_runtime": "11.5",
        "love_payload": {
            "bytes": love_file.stat().st_size,
            "sha256": sha256(love_file),
        },
        "executable": {
            "path": f"{PRODUCT}.exe",
            "bytes": target_exe.stat().st_size,
            "sha256": sha256(target_exe),
            "branding": branding,
            "signing": "unsigned",
        },
        "files": file_records,
    }
    (stage / "manifest.json").write_text(
        json.dumps(manifest, indent=2) + "\n", encoding="utf-8"
    )

    DIST.mkdir(parents=True, exist_ok=True)
    zip_path = DIST / ZIP_NAME
    zip_tree(stage, zip_path)
    with zipfile.ZipFile(zip_path) as archive:
        bad = archive.testzip()
        if bad:
            raise SystemExit(f"Windows ZIP integrity failed at {bad}")

    manifest["artifact"] = {
        "path": zip_path.name,
        "bytes": zip_path.stat().st_size,
        "sha256": sha256(zip_path),
    }
    manifest_path = DIST / "Groove-Bound-Windows-x64.manifest.json"
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    sums = [
        f"{sha256(love_file)}  {love_file.name}",
        f"{sha256(target_exe)}  {target_exe.name}",
        f"{sha256(zip_path)}  {zip_path.name}",
    ]
    (DIST / "SHA256SUMS-Windows.txt").write_text("\n".join(sums) + "\n", encoding="utf-8")
    print(json.dumps(manifest, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
