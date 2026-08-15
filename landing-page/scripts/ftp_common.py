#!/usr/bin/env python3
"""Shared FTP, FTPS, and macOS Keychain helpers for the Groove Bound site."""

from __future__ import annotations

import ftplib
import json
import os
import subprocess
from pathlib import Path, PurePosixPath


ROOT = Path(__file__).resolve().parents[1]
CONFIG_PATH = ROOT / "site-deployment.json"


def load_config() -> dict[str, object]:
    return json.loads(CONFIG_PATH.read_text(encoding="utf-8"))


def keychain_password(service: str, account: str) -> str:
    env_password = os.environ.get("GROOVE_BOUND_FTP_PASSWORD")
    if env_password:
        return env_password
    result = subprocess.run(
        ["/usr/bin/security", "find-generic-password", "-s", service, "-a", account, "-w"],
        text=True,
        capture_output=True,
    )
    if result.returncode:
        raise RuntimeError(
            f"Missing macOS Keychain credential '{service}' for '{account}'. "
            "Run: python3 scripts/setup_site_ftp_credentials.py --copy-existing"
        )
    password = result.stdout.strip()
    if not password:
        raise RuntimeError(f"macOS Keychain credential '{service}' is empty")
    return password


def _connect_with_protocol(config: dict[str, object], password: str, protocol: str) -> ftplib.FTP:
    ftp: ftplib.FTP = ftplib.FTP_TLS() if protocol == "ftps" else ftplib.FTP()
    ftp.connect(str(config["host"]), int(config.get("port", 21)), timeout=30)
    ftp.login(str(config["username"]), password)
    if isinstance(ftp, ftplib.FTP_TLS):
        ftp.prot_p()
    ftp.set_pasv(True)
    setattr(ftp, "groove_bound_protocol", protocol)
    return ftp


def connect(config: dict[str, object] | None = None) -> ftplib.FTP:
    config = config or load_config()
    password = keychain_password(str(config["ftp_keychain_service"]), str(config["username"]))
    configured = str(config.get("protocol", "auto")).lower()
    protocols = [configured] if configured in {"ftp", "ftps"} else ["ftps", "ftp"]
    errors: list[str] = []
    for protocol in protocols:
        try:
            return _connect_with_protocol(config, password, protocol)
        except ftplib.all_errors as exc:
            errors.append(f"{protocol}: {exc}")
    raise RuntimeError("Could not connect to the site host (" + "; ".join(errors) + ")")


def remote_root(config: dict[str, object] | None = None) -> PurePosixPath:
    config = config or load_config()
    webroot = str(config.get("webroot", "")).strip("/")
    site_root = str(config.get("remote_root", "groovebound")).strip("/")
    return PurePosixPath(webroot) / site_root if webroot else PurePosixPath(site_root)


def close(ftp: ftplib.FTP) -> None:
    try:
        ftp.quit()
    except Exception:
        ftp.close()


def ensure_dir(ftp: ftplib.FTP, path: PurePosixPath | str) -> None:
    ftp.cwd("/")
    for part in PurePosixPath(path).parts:
        if part in {"", "/"}:
            continue
        try:
            ftp.cwd(part)
        except ftplib.error_perm:
            ftp.mkd(part)
            ftp.cwd(part)


def cwd_existing(ftp: ftplib.FTP, path: PurePosixPath | str) -> None:
    ftp.cwd("/")
    for part in PurePosixPath(path).parts:
        if part not in {"", "/"}:
            ftp.cwd(part)


def list_dir(ftp: ftplib.FTP, path: PurePosixPath | str) -> list[str]:
    cwd_existing(ftp, path)
    try:
        return sorted(name for name, _facts in ftp.mlsd())
    except (AttributeError, ftplib.error_perm):
        return sorted(PurePosixPath(name).name for name in ftp.nlst())


def download_if_present(ftp: ftplib.FTP, remote: PurePosixPath, local: Path) -> bool:
    try:
        cwd_existing(ftp, remote.parent)
        chunks: list[bytes] = []
        ftp.retrbinary(f"RETR {remote.name}", chunks.append)
    except ftplib.error_perm as exc:
        if str(exc).startswith("550"):
            return False
        raise
    local.parent.mkdir(parents=True, exist_ok=True)
    local.write_bytes(b"".join(chunks))
    return True


def upload_atomic(ftp: ftplib.FTP, local: Path, remote: PurePosixPath, token: str) -> None:
    ensure_dir(ftp, remote.parent)
    temporary_name = f".{remote.name}.upload-{token}"
    with local.open("rb") as handle:
        ftp.storbinary(f"STOR {temporary_name}", handle, blocksize=1024 * 256)
    ftp.voidcmd("TYPE I")
    uploaded_size = ftp.size(temporary_name)
    expected_size = local.stat().st_size
    if uploaded_size != expected_size:
        try:
            ftp.delete(temporary_name)
        finally:
            raise RuntimeError(
                f"Remote size mismatch for {remote}: expected {expected_size}, got {uploaded_size}"
            )
    try:
        ftp.rename(temporary_name, remote.name)
    except ftplib.error_perm:
        try:
            ftp.delete(remote.name)
        except ftplib.error_perm as exc:
            if not str(exc).startswith("550"):
                raise
        ftp.rename(temporary_name, remote.name)
