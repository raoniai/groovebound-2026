---
name: groove-bound-release-verification
description: Verify, package, and report a Groove Bound Lua/LÖVE change. Use when asked to test, lint, package, create a release candidate, prepare a commit or push, open the packaged game, verify delivery, calculate an artifact hash, or distinguish local, committed, pushed, merged, released, deployed, and public-live states.
---

# Groove Bound release verification

Prove each delivery layer independently and protect unrelated working changes.

## Workflow

1. Read `LATEST_VERSION_HANDOVER.md` and [references/release-gates.md](references/release-gates.md).
2. Inspect branch, upstream, remote, status, diff, and untracked files. Resolve the exact requested scope before staging anything.
3. Run from `groove-bound/`:
   - `make test`
   - `make lint`
   - `git diff --check`
   - `make package`
4. Verify `dist/groove-bound.love` with an archive integrity check.
5. Run `scripts/release_manifest.py` to report artifact contents, size, hash, commit, branch, and dirty state.
6. Run packaged boot smoke in a display-capable context. Do not interpret headless SDL/OpenGL failure as a demonstrated game failure.
7. Perform or explicitly defer the manual campaign, interface, media, controller, and changed-feature checks.
8. Stage only requested files when commit is authorized. Verify the destination branch and remote before push.
9. Update `LATEST_VERSION_HANDOVER.md` after material accepted work.
10. Report every delivery state separately.

## Hard rules

- Do not claim manual playthrough from automated tests or boot smoke.
- Do not claim main-branch completion from a feature-branch push.
- Do not claim release, deployment, or public-live state without direct evidence.
- Do not include source candidates, tests, docs, or reference MP4 files in the game archive.
- Do not sign, notarize, publish, or use credentials without explicit authority.
