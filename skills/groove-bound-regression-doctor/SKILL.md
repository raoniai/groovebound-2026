---
name: groove-bound-regression-doctor
description: Diagnose Groove Bound bugs and regressions with deterministic reproduction and evidence. Use for crashes, incorrect combat or progression, enemy navigation, collision, state transitions, controller input, save failures, missing assets, package-only faults, visual glitches, cutscene timing, audio routing, or behavior that differs between source and packaged builds.
---

# Groove Bound regression doctor

Prove the failure boundary and cause before widening the change.

## Diagnose

1. Read `LATEST_VERSION_HANDOVER.md`, inspect current changes, and read [references/diagnosis-map.md](references/diagnosis-map.md).
2. Capture the smallest reproduction: branch or commit, dirty state, seed, character, stage, Admin settings, device, source or package, expected result, and observed result.
3. Classify the fault as simulation, rendering, input, UI state, media, asset mapping, persistence, packaging, or platform-specific behavior.
4. Reproduce with the narrowest test or controlled run. Compare source and package when relevant.
5. Trace ownership and lifecycle instead of patching the visible symptom.
6. Add a failing regression test when the behavior is mechanically observable.
7. If the request includes a fix, implement the smallest owner-level correction and run focused plus full checks.
8. If the request is diagnosis-only, stop after proving the cause and fix direction.
9. Report unverified graphical, audio, controller, or platform evidence explicitly.

## Evidence standard

Separate cause, contributing conditions, observed symptom, implemented correction, regression proof, manual proof, and remaining uncertainty.
