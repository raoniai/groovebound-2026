#!/usr/bin/env python3
"""Store the Groove Bound FTP password in macOS Keychain."""

from __future__ import annotations

import argparse
import getpass
import subprocess

from ftp_common import load_config


def read_keychain(service: str, account: str) -> str | None:
    result = subprocess.run(
        ["/usr/bin/security", "find-generic-password", "-s", service, "-a", account, "-w"],
        text=True,
        capture_output=True,
    )
    return result.stdout.strip() if result.returncode == 0 else None


def save_keychain(service: str, account: str, password: str) -> None:
    subprocess.run(
        [
            "/usr/bin/security",
            "add-generic-password",
            "-U",
            "-s",
            service,
            "-a",
            account,
            "-w",
            password,
        ],
        check=True,
        capture_output=True,
    )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--copy-existing",
        action="store_true",
        help="Copy the existing raoni.ai FTP credential into the dedicated Groove Bound service",
    )
    args = parser.parse_args()
    config = load_config()
    service = str(config["ftp_keychain_service"])
    account = str(config["username"])
    if read_keychain(service, account):
        print(f"Keychain credential already configured: {service} / {account}")
        return 0
    password: str | None = None
    if args.copy_existing:
        fallback = str(config.get("fallback_keychain_service", ""))
        if fallback:
            password = read_keychain(fallback, account)
        if not password:
            raise RuntimeError(
                f"Existing Keychain credential '{fallback}' for '{account}' was not found. "
                "Run this command without --copy-existing to enter the password securely."
            )
    else:
        password = getpass.getpass(f"FTP password for {account}: ")
    if not password:
        raise RuntimeError("FTP password cannot be blank")
    save_keychain(service, account, password)
    print(f"Keychain credential saved: {service} / {account}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"credential setup error: {exc}")
        raise SystemExit(1)
