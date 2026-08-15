---
name: groove-bound-version-sync
description: Enforce one Groove Bound version across canonical source, loose-folder runtime labels, the common LOVE payload, macOS and Windows packages, GitHub Latest assets, and the public landing pages. Use before and after any GitHub release upload, desktop artifact replacement, landing deployment, public version update, or investigation of conflicting builds and downloads.
---

# Groove Bound version sync

Treat `groove-bound/VERSION` as the only editable release-number source. Never
repair generated artifacts or public pages by relabelling an older payload.

## Run the gate

1. Resolve the clean release commit and confirm `VERSION` is the intended next
   numeric version.
2. Before packaging, run `scripts/check_version_sync.py --root <repo> --scope source`.
3. Build the common `.love` once. Build native packages only from that exact
   payload, then run the checker with `--scope local`.
4. Before a GitHub upload, compare every candidate name, embedded version,
   common-payload hash, native manifest, and checksum ledger with
   `--scope candidate --assets-dir <downloaded-assets>`. Stop on drift.
5. After GitHub publication, run `--scope github`; require GitHub Latest to be
   the source version and all required assets to exist with digests.
6. Before landing deployment, require the local Home, Catalog, and Builder
   badges to match GitHub Latest while retaining stable Latest download URLs.
7. After an approved deployment, run `--scope public`; require all three live
   pages and GitHub Latest to agree.
8. Record source, package, GitHub, landing deployment, and public-live states
   independently in `LATEST_VERSION_HANDOVER.md`.

## Hard gates

- Fail if loose source cannot show `v<version>-dev` or packaged builds cannot
  show `v<version>` from `release-build.txt`.
- Fail if macOS, Windows, and common payload hashes or embedded versions differ.
- Fail if a landing badge trails or leads GitHub Latest.
- Never upload, replace downloads, deploy, sign, notarize, or use credentials
  without explicit authority.
- Never call a local candidate released, deployed, or public-live.
