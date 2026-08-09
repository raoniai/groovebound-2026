---
name: groove-bound-latest-handover
description: Read, refresh, validate, or use Groove Bound's canonical latest-version handover database. Use when starting or resuming work, asking what the latest version contains, handing the project to another agent or person, reporting current branch and verification state, recording accepted decisions, closing a material task, or reconciling documentation with live repository evidence.
---

# Groove Bound latest-version handover

Maintain `LATEST_VERSION_HANDOVER.md` as the authoritative continuation record while keeping generated evidence and human decisions distinct.

## Read mode

1. Open the handover before substantial Groove Bound work.
2. Verify mutable claims against live Git and executable checks when they affect the task.
3. Treat the generated snapshot as evidence captured at its timestamp, not permanent truth.
4. Use the handover to resolve canonical sources, accepted behavior, partial work, open risks, delivery state, and next safe actions.

## Update mode

1. Read [references/handover-schema.md](references/handover-schema.md).
2. Inspect the requested task, actual changed files, verification evidence, manual evidence, version-control state, and external state.
3. Run `scripts/update_handover.py --run-checks` to refresh the delimited live snapshot after material changes. Omit `--run-checks` only when checks are unsafe or outside scope, then record them as not run.
4. Edit curated sections with precise statuses. Preserve unresolved criteria and unrelated work.
5. Add or update the continuation entry with outcome, evidence, remaining work, and next safe action.
6. Validate that no generated artifact, local preview, feature-branch push, or stale prose is reported as a later delivery state.
7. Keep secrets, private source material, credentials, and personal data out of the handover.

## Authority rules

- Let live Git and executable checks override stale counts and prose.
- Let approved product decisions override agent guesses.
- Keep the handover human-readable; do not turn it into a raw log dump.
- Preserve history through concise continuation entries rather than deleting unresolved context.
