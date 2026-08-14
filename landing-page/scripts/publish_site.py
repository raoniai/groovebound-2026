#!/usr/bin/env python3
"""Dry-run, inspect, publish, roll back, and verify the Groove Bound static site."""

from __future__ import annotations

import argparse
import hashlib
import json
import shutil
import subprocess
import tempfile
import time
from datetime import datetime, timezone
from pathlib import Path, PurePosixPath
from urllib.parse import urlparse

from build_site_release import build_release
from ftp_common import close, connect, download_if_present, list_dir, load_config, remote_root, upload_atomic


ROOT = Path(__file__).resolve().parents[1]
ROLLBACK_ROOT = ROOT / ".deployment" / "rollbacks"
ROLLBACK_FILES = ("index.html", "catalog.html", "builder.html", "styles.css", "script.js", "status-data.js")
REPRESENTATIVE_ASSETS = (
    "assets/groove-bound-title.png",
    "assets/prologue-logo.png",
    "assets/world-tour/logos/world-tour-header-logo-festival.png",
)
LATEST_DOWNLOADS = {
    "macOS": ("Groove-Bound-macOS.dmg",),
    "Windows": ("Groove-Bound-Windows-x64.zip",),
}


def run_version_gate(scope: str, release: str) -> None:
    repository = ROOT.parent
    checker = repository / "skills/groove-bound-version-sync/scripts/check_version_sync.py"
    subprocess.run(
        [
            "python3", str(checker), "--root", str(repository),
            "--scope", scope, "--version", release,
        ],
        check=True,
    )


def sha256_bytes(payload: bytes) -> str:
    return hashlib.sha256(payload).hexdigest()


def manifest_files(build_dir: Path) -> list[str]:
    data = json.loads((build_dir / "site-manifest.json").read_text(encoding="utf-8"))
    return [str(item["path"]) for item in data["files"]]


def upload_order(relative: str) -> tuple[int, str]:
    suffix = Path(relative).suffix.lower()
    if relative.startswith("assets/"):
        return (0, relative)
    if suffix in {".css", ".js"}:
        return (1, relative)
    if suffix == ".html":
        return (2, relative)
    return (1, relative)


def save_rollback(ftp, root: PurePosixPath, release: str) -> Path:
    stamp = datetime.now().astimezone().strftime("%Y%m%d-%H%M%S")
    rollback_dir = ROLLBACK_ROOT / f"{stamp}-{release}"
    records: list[dict[str, object]] = []
    for relative in ROLLBACK_FILES:
        local = rollback_dir / relative
        present = download_if_present(ftp, root / relative, local)
        record: dict[str, object] = {"path": relative, "present": present}
        if present:
            payload = local.read_bytes()
            record.update({"bytes": len(payload), "sha256": sha256_bytes(payload)})
        records.append(record)
    rollback_dir.mkdir(parents=True, exist_ok=True)
    (rollback_dir / "rollback-manifest.json").write_text(
        json.dumps(
            {
                "captured_at": datetime.now(timezone.utc).isoformat(timespec="seconds"),
                "release": release,
                "remote_root": str(root),
                "files": records,
            },
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )
    return rollback_dir


def fetch(url: str, *, method: str = "GET", timeout: int = 45):
    with tempfile.NamedTemporaryFile() as output:
        command = [
            "/usr/bin/curl",
            "--fail",
            "--silent",
            "--show-error",
            "--location",
            "--max-redirs",
            "10",
            "--connect-timeout",
            "15",
            "--max-time",
            str(timeout),
            "--user-agent",
            "Groove-Bound-Site-Publisher/1.0",
            "--output",
            output.name,
            "--write-out",
            "%{http_code}\t%{url_effective}\t%{content_type}\t%{size_download}",
        ]
        if method == "HEAD":
            command.append("--head")
        command.append(url)
        result = subprocess.run(command, text=True, capture_output=True)
        if result.returncode:
            raise RuntimeError(f"HTTPS verification failed for {url}: {result.stderr.strip()}")
        parts = result.stdout.strip().split("\t")
        if len(parts) != 4 or parts[0] != "200":
            raise RuntimeError(f"Unexpected HTTPS response for {url}: {result.stdout.strip()}")
        output.seek(0)
        payload = output.read()
        return payload, parts[1], {
            "Status": parts[0],
            "Content-Type": parts[2],
            "Content-Length": parts[3] if method != "HEAD" else "",
        }


def verify_public(build_dir: Path, config: dict[str, object], release: str) -> None:
    base = str(config["public_url"]).rstrip("/") + "/"
    cache = str(int(time.time()))
    checks = {
        "index.html": ("Version", release, "The complete Prologue", "Coming soon"),
        "catalog.html": ("Version", release, "Resonance Archive"),
        "builder.html": ("Version", release, "Your next run starts here"),
        "styles.css": (),
        "script.js": ("Beyond the tour map", "Make every choice feel alive"),
        "status-data.js": (),
    }
    for relative, phrases in checks.items():
        payload, _final_url, _headers = fetch(f"{base}{relative}?deploy={cache}")
        local = (build_dir / relative).read_bytes()
        if payload != local:
            raise RuntimeError(f"Public bytes do not match the release for {relative}")
        text = payload.decode("utf-8", errors="ignore")
        for phrase in phrases:
            if phrase not in text:
                raise RuntimeError(f"Public verification phrase missing from {relative}: {phrase}")
        print(f"verified public bytes: {relative}")
    root_payload, _root_url, _root_headers = fetch(f"{base}?deploy={cache}")
    if root_payload != (build_dir / "index.html").read_bytes():
        raise RuntimeError("Public directory index does not match index.html")
    print("verified public directory index")
    for relative in REPRESENTATIVE_ASSETS:
        payload, _final_url, _headers = fetch(f"{base}{relative}?deploy={cache}")
        local = (build_dir / relative).read_bytes()
        if payload != local:
            raise RuntimeError(f"Public asset does not match the release: {relative}")
        print(f"verified public asset: {relative}")
    release_payload, _release_url, _release_headers = fetch(
        "https://api.github.com/repos/raoniai/groovebound-2026/releases/latest"
    )
    release_data = json.loads(release_payload)
    if release_data.get("tag_name") != release:
        raise RuntimeError(f"GitHub Latest is {release_data.get('tag_name')}, expected {release}")
    release_assets = {asset["name"]: asset for asset in release_data.get("assets", [])}
    for label, (asset_name,) in LATEST_DOWNLOADS.items():
        asset = release_assets.get(asset_name, {})
        expected_size = int(asset.get("size", -1))
        expected_digest = str(asset.get("digest", ""))
        if expected_size < 1 or not expected_digest.startswith("sha256:"):
            raise RuntimeError(f"{label} GitHub release metadata is incomplete")
        url = (
            "https://github.com/raoniai/groovebound-2026/releases/latest/download/"
            + asset_name
        )
        _payload, final_url, headers = fetch(url, method="HEAD")
        length = headers.get("Content-Length")
        if length and int(length) != expected_size:
            raise RuntimeError(f"{label} Latest size mismatch: expected {expected_size}, got {length}")
        print(
            f"verified GitHub Latest: {label} -> {release_data['tag_name']} "
            f"({length or expected_size} bytes; final host {urlparse(final_url).netloc})"
        )


def inspect_remote(config: dict[str, object]) -> None:
    ftp = connect(config)
    try:
        root = remote_root(config)
        entries = list_dir(ftp, root)
        protocol = getattr(ftp, "groove_bound_protocol", "unknown")
        print(f"protocol: {protocol}")
        print(f"remote root: /{root}")
        print(f"existing entries: {len(entries)}")
        for entry in entries[:20]:
            print(f"  {entry}")
    finally:
        close(ftp)


def dry_run(build_dir: Path, config: dict[str, object]) -> None:
    root = remote_root(config)
    for relative in sorted(manifest_files(build_dir), key=upload_order):
        print(f"{relative} -> /{root / relative}")


def publish(build_dir: Path, config: dict[str, object], release: str, skip_web_check: bool) -> None:
    ftp = connect(config)
    root = remote_root(config)
    token = datetime.now(timezone.utc).strftime("%Y%m%d%H%M%S")
    try:
        entries = list_dir(ftp, root)
        print(
            f"confirmed remote root: /{root} via "
            f"{getattr(ftp, 'groove_bound_protocol', 'unknown')} ({len(entries)} existing entries)"
        )
        rollback_dir = save_rollback(ftp, root, release)
        shutil.copy2(build_dir / "site-manifest.json", rollback_dir / "published-site-manifest.json")
        print(f"rollback saved: {rollback_dir}")
        files = sorted(manifest_files(build_dir), key=upload_order)
        for index, relative in enumerate(files, start=1):
            upload_atomic(ftp, build_dir / relative, root / relative, token)
            print(f"uploaded {index}/{len(files)}: /{root / relative}")
    finally:
        close(ftp)
    if not skip_web_check:
        verify_public(build_dir, config, release)
        run_version_gate("public", release)
        print("public verification complete")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--release", help="Release label, required with --publish")
    parser.add_argument("--publish", action="store_true", help="Perform the live upload; otherwise run locally")
    parser.add_argument("--inspect-remote", action="store_true", help="Read-only remote path and protocol check")
    parser.add_argument("--verify-public", action="store_true", help="Build locally and verify the existing public site")
    parser.add_argument("--skip-web-check", action="store_true", help="Skip public HTTPS verification after upload")
    args = parser.parse_args()
    config = load_config()
    if args.inspect_remote:
        inspect_remote(config)
        return 0
    if args.publish and not args.release:
        parser.error("--release is required with --publish")
    release = args.release or str(config["release"])
    run_version_gate("landing", release)
    if args.publish or args.verify_public:
        run_version_gate("github", release)
    with tempfile.TemporaryDirectory(prefix=f"groove-bound-publish-{release}-") as directory:
        build_dir = Path(directory)
        manifest = build_release(release, build_dir)
        print(f"built release: {manifest['file_count']} files, {manifest['total_bytes']} bytes")
        if args.verify_public:
            verify_public(build_dir, config, release)
            print("public verification complete")
        elif args.publish:
            publish(build_dir, config, release, args.skip_web_check)
        else:
            dry_run(build_dir, config)
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"publish error: {exc}")
        raise SystemExit(1)
