# Latest handover schema

## Required sections

1. Authority and update protocol.
2. Generated live snapshot between stable markers.
3. Current product version and player-facing flow.
4. Canonical source map.
5. System status with evidence and open acceptance.
6. Active working state and protected changes.
7. Verification and delivery ledger.
8. Platform and engine-port state.
9. Risks, blockers, and approval gates.
10. Next safe actions.
11. Continuation history.

## Status vocabulary

Use planned, drafted, locally implemented, tests passed, package verified, manual QA verified, committed, pushed, merged, released, deployed, and public-live verified. Combine states only when each is evidenced.

## Generated versus curated

The update script owns only the text between `LIVE-SNAPSHOT` markers. Humans or agents curate every other section. Never place decisions or manual-QA claims inside the generated block.

## Update triggers

Refresh after accepted feature work, balance changes, asset integration, package verification, commit or push, release, deployment, platform proof, migration gate, or a changed canonical decision.
