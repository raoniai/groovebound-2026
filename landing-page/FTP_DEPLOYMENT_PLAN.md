# Groove Bound landing-page FTP deployment plan

## Implementation status

Implemented on 2026-08-13 under `landing-page/scripts/`:

- `build_site_release.py` builds and hashes an allowlisted public package.
- `setup_site_ftp_credentials.py` stores a dedicated Keychain credential and
  can copy the existing raoni.ai FTP credential without exposing it.
- `publish_site.py` defaults to dry-run, supports read-only remote inspection,
  captures rollback files, uploads atomically in dependency order, and verifies
  the public site and GitHub Latest routes.
- `site-deployment.json` records only non-secret host, route, and Keychain
  service metadata.

Rollback bundles are stored in the ignored `landing-page/.deployment/` folder.
No credential is written to the repository.

The first supervised deployment completed on 2026-08-13. The server accepted
encrypted FTPS, the remote root resolved to
`/public_html/raoni.ai/groovebound`, 353 public files were uploaded in dependency
order, and Home, Catalog, Builder, shared code, representative campaign assets,
and both GitHub Latest routes passed public verification. The configuration now
requires FTPS rather than falling back to unencrypted FTP.

## Outcome

Replace manual FTP work with one approval-gated command that packages the
verified static site, uploads it to the existing Groove Bound destination, and
checks the public pages after the upload.

## Canonical source and destination

- Local source: `landing-page/`
- Public URL: `https://raoni.ai/groovebound/`
- Expected remote root: `/public_html/raoni.ai/groovebound/`
- Existing hosting account pattern: `raoni@raoni.studio` on
  `ftp.raoni.studio`

The remote root and protocol must be confirmed with a read-only connection
before the first upload. Prefer FTPS when the host supports it; otherwise retain
the current passive FTP behavior used by the existing raoni.ai publisher.

## Recommended implementation

The implementation contains three repository-owned entrypoints:

1. `scripts/build_site_release.py`
   - Copies only public HTML, CSS, JavaScript, fonts, images, audio, and video
     into a temporary release directory.
   - Excludes `source-candidates/`, research, scripts, changelogs, deployment
     notes, PSDs, generated sources, credentials, and development-only files.
   - Verifies local references, forbidden extensions, file count, byte size,
     and SHA-256 hashes before producing `site-manifest.json`.
2. `scripts/setup_site_ftp_credentials.py`
   - Prompts once for the FTP password and stores it in macOS Keychain under a
     dedicated `groove-bound-ftp` service.
   - Never writes the password to this repository, a shell history, or a config
     file.
3. `scripts/publish_site.py`
   - Defaults to `--dry-run` and prints the exact local-to-remote manifest.
   - Requires an explicit release value such as `--release v0.8.0` before a live
     upload.
   - Uploads assets first, then CSS and JavaScript, and HTML last so visitors do
     not receive pages that reference files that have not arrived yet.
   - Uploads each file to a temporary remote name, verifies its size, then
     renames it into place. It does not delete remote files by default.
   - Saves the previous public HTML, CSS, and JavaScript locally as a dated
     rollback bundle before replacement.
   - Verifies Home, Catalog, Builder, the v0.8.0 badge, representative assets,
     and both GitHub Latest download routes over HTTPS after publishing.

## First implementation sequence

1. Confirm whether the host accepts FTPS and confirm the remote root with a
   read-only directory listing.
2. Build the allowlisted release packager and forbidden-file checks.
3. Add Keychain setup without committing any credential or secret-bearing
   configuration.
4. Run a local build and FTP dry-run; review the manifest together.
5. Perform the first live upload only after explicit approval.
6. Verify `https://raoni.ai/groovebound/`, `/catalog.html`, and `/builder.html`
   with cache-busting query strings and record the public-live result.

## Later automation options

- Preferred: an assistant-triggered local publisher using macOS Keychain. This
  gives a one-command upload while keeping every external change approval-gated.
- Optional: a GitHub Actions deployment after the landing source is committed
  and the hosting credentials are stored as repository secrets. This should be
  considered only if automatic deployment from an approved branch is desired.
- Do not schedule unattended uploads until rollback, remote-path validation,
  and public verification have succeeded in at least one supervised release.
