#!/usr/bin/env python3
"""Fail closed when Groove Bound version surfaces disagree."""

from __future__ import annotations

import argparse
import hashlib
import json
import plistlib
import re
import subprocess
import urllib.error
import urllib.request
import zipfile
from pathlib import Path


REQUIRED_ASSETS = {
    "Groove-Bound-macOS.dmg",
    "Groove-Bound-macOS.zip",
    "Groove-Bound-Windows-x64.manifest.json",
    "Groove-Bound-Windows-x64.zip",
    "groove-bound.love",
    "SHA256SUMS-Desktop.txt",
    "SHA256SUMS-Windows.txt",
}
PAGES = ("index.html", "catalog.html", "builder.html")
LATEST_ROOT = "https://github.com/raoniai/groovebound-2026/releases/latest/download/"


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def fetch(url: str) -> bytes:
    request = urllib.request.Request(url, headers={"User-Agent": "groove-bound-version-sync"})
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            return response.read()
    except urllib.error.URLError:
        result = subprocess.run(
            ("curl", "-fsSL", "--max-time", "30", url),
            check=True, capture_output=True,
        )
        return result.stdout


def parse_marker(contents: str) -> dict[str, str]:
    return dict(line.split("=", 1) for line in contents.splitlines() if "=" in line)


class Check:
    def __init__(self, root: Path, version: str):
        self.root = root
        self.game = root / "groove-bound"
        self.dist = self.game / "dist"
        self.version = version
        self.passed: list[str] = []
        self.errors: list[str] = []

    def require(self, condition: bool, message: str) -> None:
        (self.passed if condition else self.errors).append(message)

    def source(self) -> None:
        self.require(bool(re.fullmatch(r"\d+\.\d+\.\d+", self.version)),
                     "VERSION is numeric dotted semver")
        build_info = (self.game / "src/config/build_info.lua").read_text(encoding="utf-8")
        self.require('"v" .. source_version .. "-dev"' in build_info,
                     "loose source exposes an explicit dev label")
        for relative in ("src/ui/screens/title.lua", "src/ui/screens/pause.lua"):
            text = (self.game / relative).read_text(encoding="utf-8")
            self.require(
                "BuildInfo.label()" in text or "BuildInfo.version_label()" in text,
                f"{relative} renders canonical build identity",
            )

    def love_payload(self, path: Path | None = None) -> None:
        path = path or self.dist / "groove-bound.love"
        self.require(path.is_file(), "common LOVE payload exists")
        if not path.is_file():
            return
        try:
            with zipfile.ZipFile(path) as archive:
                bad = archive.testzip()
                marker = parse_marker(archive.read("release-build.txt").decode("utf-8"))
                archived_version = archive.read("VERSION").decode("utf-8").strip()
                names = set(archive.namelist())
        except (KeyError, zipfile.BadZipFile, UnicodeDecodeError) as error:
            self.errors.append(f"common LOVE payload is unreadable: {error}")
            return
        self.require(bad is None, "common LOVE archive integrity passes")
        self.require(marker.get("profile") == "release", "common payload uses release profile")
        self.require(marker.get("version") == self.version, "common payload marker matches VERSION")
        self.require(archived_version == self.version, "archived VERSION matches source VERSION")
        self.require(not any("\r" in name or "\n" in name for name in names),
                     "common payload contains no control-character filenames")

    def native(self) -> None:
        love_path = self.dist / "groove-bound.love"
        love_hash = sha256(love_path) if love_path.is_file() else None
        mac_zip = self.dist / "Groove-Bound-macOS.zip"
        if mac_zip.is_file():
            with zipfile.ZipFile(mac_zip) as archive:
                plist_name = next(name for name in archive.namelist()
                                  if name.endswith("Contents/Info.plist"))
                love_name = next(name for name in archive.namelist()
                                 if name.endswith("Contents/Resources/Groove Bound.love"))
                plist = plistlib.loads(archive.read(plist_name))
                embedded_hash = hashlib.sha256(archive.read(love_name)).hexdigest()
            self.require(plist.get("CFBundleShortVersionString") == self.version,
                         "macOS bundle version matches VERSION")
            self.require(embedded_hash == love_hash, "macOS bundle embeds the common payload")
        windows_manifest = self.dist / "Groove-Bound-Windows-x64.manifest.json"
        if windows_manifest.is_file():
            data = json.loads(windows_manifest.read_text(encoding="utf-8"))
            self.require(data.get("version") == self.version,
                         "Windows manifest version matches VERSION")
            self.require(data.get("love_payload", {}).get("sha256") == love_hash,
                         "Windows bundle embeds the common payload")

    def candidate(self, assets_dir: Path) -> None:
        files = {path.name: path for path in assets_dir.rglob("*") if path.is_file()}
        self.require(REQUIRED_ASSETS <= set(files), "candidate has every required asset")
        love_path = files.get("groove-bound.love")
        if not love_path:
            return
        self.love_payload(love_path)
        love_hash = sha256(love_path)
        mac_zip = files.get("Groove-Bound-macOS.zip")
        if mac_zip:
            with zipfile.ZipFile(mac_zip) as archive:
                plist_name = next(name for name in archive.namelist()
                                  if name.endswith("Contents/Info.plist"))
                love_name = next(name for name in archive.namelist()
                                 if name.endswith("Contents/Resources/Groove Bound.love"))
                plist = plistlib.loads(archive.read(plist_name))
                embedded_hash = hashlib.sha256(archive.read(love_name)).hexdigest()
            self.require(plist.get("CFBundleShortVersionString") == self.version,
                         "candidate macOS bundle version matches VERSION")
            self.require(embedded_hash == love_hash,
                         "candidate macOS bundle embeds the common payload")
        manifest_path = files.get("Groove-Bound-Windows-x64.manifest.json")
        if manifest_path:
            manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
            self.require(manifest.get("version") == self.version,
                         "candidate Windows manifest version matches VERSION")
            self.require(manifest.get("love_payload", {}).get("sha256") == love_hash,
                         "candidate Windows bundle embeds the common payload")

    def landing(self, live: bool = False) -> None:
        for page in PAGES:
            if live:
                suffix = "" if page == "index.html" else page
                text = fetch("https://raoni.ai/groovebound/" + suffix).decode()
                label = "live " + page
            else:
                text = (self.root / "landing-page" / page).read_text(encoding="utf-8")
                label = "local " + page
            self.require(f"releases/tag/v{self.version}" in text,
                         f"{label} badge links to v{self.version}")
            self.require(f"<strong>v{self.version}</strong>" in text,
                         f"{label} displays v{self.version}")
            self.require(LATEST_ROOT + "Groove-Bound-macOS.dmg" in text,
                         f"{label} uses stable macOS Latest URL")
            self.require(LATEST_ROOT + "Groove-Bound-Windows-x64.zip" in text,
                         f"{label} uses stable Windows Latest URL")

    def github(self) -> None:
        data = json.loads(fetch(
            "https://api.github.com/repos/raoniai/groovebound-2026/releases/latest").decode())
        self.require(data.get("tag_name") == f"v{self.version}",
                     f"GitHub Latest is v{self.version}")
        assets = {item["name"]: item for item in data.get("assets", [])}
        self.require(REQUIRED_ASSETS <= set(assets), "GitHub Latest has every required asset")
        for name in REQUIRED_ASSETS & set(assets):
            self.require(str(assets[name].get("digest", "")).startswith("sha256:"),
                         f"GitHub asset {name} has a SHA-256 digest")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[3])
    parser.add_argument("--version", help="audit an already-public version instead of VERSION")
    parser.add_argument("--scope", choices=(
        "source", "local", "candidate", "landing", "github", "public"),
                        default="source")
    parser.add_argument("--assets-dir", type=Path,
                        help="downloaded release candidate root for candidate scope")
    args = parser.parse_args()
    root = args.root.resolve()
    source_version = (root / "groove-bound/VERSION").read_text(encoding="utf-8").strip()
    check = Check(root, (args.version or source_version).lstrip("v"))

    if args.scope in {"source", "local"}:
        check.source()
    if args.scope == "local":
        check.love_payload()
        check.native()
    if args.scope == "candidate":
        if not args.assets_dir:
            parser.error("--assets-dir is required with --scope candidate")
        check.source()
        check.candidate(args.assets_dir.resolve())
    if args.scope == "landing":
        check.landing()
    if args.scope in {"github", "public"}:
        check.github()
    if args.scope == "public":
        check.landing(live=True)

    result = {"scope": args.scope, "version": check.version,
              "passed": check.passed, "errors": check.errors}
    print(json.dumps(result, indent=2))
    return 1 if check.errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
