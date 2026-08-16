# Groove Bound landing page

The static site has three public pages: Home, Catalog, and Builder. The complete
campaign story is integrated into Home rather than split into a separate page.

After every material game or landing-page change:

1. Add a landing-page entry to `CHANGELOG.md` when the site changes.
2. Refresh the local preview.
3. Verify Home, Catalog, Builder, the integrated story route, media sound controls, catalog search and filters, the item inspector, screenshot lightboxes, drag interactions, and mobile layouts.

Every new playable world or game/playable asset must update the Catalog in the
same delivery pass. Keep each world identity or emblem in its World Tour record,
never in a separate General category. Include scenario backgrounds and floors,
environment sprites, enemy sprites, and other newly playable inventory;
refresh category and total counts; verify inspector data and asset references;
then publish and public-live verify the approved FTP release. Leave the site
local-only only when the user explicitly withholds deployment.

All public desktop download buttons use GitHub's stable Latest-release routes:
the universal macOS DMG and the Windows x64 portable ZIP. The exact version is
shown only in the top navigation badge; public page copy remains evergreen and
does not describe release-to-release changes. The GB icon is the landing-page
identity; rebuilding packaged application icons requires a separate game release.

The public landing-page status ledger was removed from the site. `CHANGELOG.md` remains the local implementation record.

## FTP deployment

The landing page has an approval-gated FTP publisher. It packages only public
site files, stores the password in macOS Keychain, captures a rollback bundle,
uploads assets before HTML, and verifies the public pages after publishing.

From `landing-page/`:

```sh
python3 scripts/build_site_release.py --release v0.9.5
python3 scripts/setup_site_ftp_credentials.py --copy-existing
python3 scripts/publish_site.py --inspect-remote
python3 scripts/publish_site.py --release v0.9.5
python3 scripts/publish_site.py --release v0.9.5 --publish
python3 scripts/publish_site.py --release v0.9.5 --verify-public
```

The publisher defaults to a local dry run. A live upload requires both
`--release` and `--publish`. Generated rollback data is kept under the ignored
`landing-page/.deployment/` directory.
