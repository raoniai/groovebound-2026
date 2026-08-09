# Groove Bound landing page

This static site reads its visible version ledger from `status-data.js`.

After every material game or landing-page change:

1. Add a new landing-page entry to the top of `CHANGELOG.md` when the site changed.
2. Run `node scripts/update-status.mjs` from this directory.
3. Refresh the local preview and verify Home, Lore, Builder, the inspector, and the Status filters on desktop and mobile.

The updater reads the complete committed game history and the current game-only working-tree count. It does not claim that unrun tests, deployment, or a public release are complete.
