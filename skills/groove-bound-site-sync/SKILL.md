---
name: groove-bound-site-sync
description: Update and verify the Groove Bound static landing site from canonical game sources. Use for Home, Lore, Builder, status ledger, copied game assets, screenshots, videos, interactive inspectors, responsive behavior, changelog entries, local previews, public presentation, or checking whether website claims match the committed game and verified delivery state.
---

# Groove Bound site sync

Keep the site a faithful public presentation of the game without making it the authority for gameplay, lore, assets, or delivery status.

## Workflow

1. Read `LATEST_VERSION_HANDOVER.md`, `landing-page/README.md`, and [references/site-contract.md](references/site-contract.md).
2. Resolve every changed fact to canonical game definitions, canon, provenance, committed history, or verified release evidence.
3. Reuse authentic assets. Compare copied website assets with their canonical sources before replacing them.
4. Add a top changelog entry for material site changes.
5. Run `node scripts/update-status.mjs` from `landing-page/` after material game or site changes.
6. Check JavaScript syntax, local references, failed assets, inspector data, status filters, and screenshot aspect ratios.
7. Verify Home, Lore, and Builder on desktop and mobile, including horizontal overflow and reduced-motion behavior.
8. Distinguish local preview, committed site, pushed site, deployment, and public-live verification.
9. Update the handover with material accepted site state.

## Guardrails

- Do not invent features, release state, dates, or lore.
- Do not force source screenshots into destructive cover crops.
- Do not replace the high-motion cinematic identity with generic marketing components.
- Do not publish or deploy without explicit authority.
