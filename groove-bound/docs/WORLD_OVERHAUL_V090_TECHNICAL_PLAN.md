# Groove Bound v0.9.0 — World Overhaul Technical Plan

## Objective

Make every playable World Tour world mechanic a deliberate risk/reward loop,
make each second stage visually unique, and turn final bosses into escalating,
pattern-driven encounters that remain challenging against powerful builds.

The implementation preserves stable world, stage, mechanic, enemy, save, and
progression identifiers. It changes presentation, tuning, and runtime behaviour
without invalidating v0.8.x profiles.

## Fixed scope

- Worlds: Funk, Soul, Disco, and Jazz.
- Stages: both authored stages in each world.
- Bosses: the stage boss and final boss for every world.
- Runtime: current LÖVE/Lua game only; no engine migration.
- UI: mechanic guidance must reserve its own layout below the top-right Score
  and Combo devices at every supported resolution.
- Art: four Stage 2 environment atlases and four world-mechanic animation
  atlases, plus individual transparent state sprites and preserved high-resolution
  generation sources.
- Release: version, source, loose build, `.love`, native packages, GitHub release,
  download metadata, FTP payload, and public version parity at `0.9.0`.

## Acceptance contract

1. Existing v0.8.x saves load without identifier migration.
2. Each world has a mechanically different success condition and reward profile.
3. Stage 2 changes the mechanic rule and uses its own environment atlas.
4. Four consecutive or configured successes create a visible Encore payoff.
5. Mechanic rewards affect combat immediately and contribute to a boss Break.
6. Bosses resist ordinary knockback, anchor during wind-up, gain attack density
   across three health phases, and rotate through at least three attack patterns.
7. Heavy hostile projectiles require multiple cancellation hits.
8. Boss range warnings are thin, stable outlines rather than large flashing fills.
9. Mechanic UI begins below the 64-pixel Score/Combo band with at least 12 pixels
   of separation; other alerts flow below its reserved rectangle.
10. Reduced-motion and reduced-flash options remain authoritative.
11. All automated tests, lint, content validation, asset checks, packaging checks,
    and release parity checks pass before publication.

## Delivery sequence

### Stage 0 — Baseline and isolation

- Freeze the clean v0.8.5 source baseline.
- Work on `codex/world-overhaul-v090` in an isolated worktree.
- Record baseline test and lint results.
- Keep the user's unrelated dirty workspace untouched.

Exit: clean baseline verified and release work isolated.

### Stage 1 — Shared world-mechanic runtime

- Replace the Funk-only owner with `WorldMechanicSystem` while retaining the old
  module as a compatibility alias.
- Track opportunities, activations, current chain, best chain, Encore count,
  boost time, charge, flow, and success state.
- Add shared combat effects for speed, damage, cadence, and boss Break.
- Add Soul recovery with overflow converted into a bounded Guard.
- Carry mechanic statistics across the two stages and expose them to results.

Exit: the shared state machine is deterministic and all stable IDs remain valid.

### Stage 2 — HUD safety and feedback

- Place the mechanic panel at `y = 76`, below Score/Combo (`y = 8`, `h = 56`).
- Publish its rectangle to the alert layout so toasts never collide with it.
- Provide world- and stage-specific action language instead of generic pad copy.
- Show chain, reward, Encore, and boss-Break feedback.
- Display best chain and Encore count on stage completion.

Exit: no mechanic explanation overlaps Score, Combo, or alert content.

### Stage 3 — Funk implementation

- Stage 1, Pocket Timing: move to the highlighted bass pad for the downbeat.
- Stage 2, Pocket Relay: follow faster linked pad cues aboard the Mothership.
- Reward: movement, weapon damage, and cadence; relay successes contribute more
  boss Break.
- Art: eight-state Pocket Pad animation and a dedicated Mothership prop atlas.

Exit: Stage 2 changes both route pressure and environment identity.

### Stage 4 — Soul implementation

- Stage 1, Resonance Charge: remain in the pool long enough to fill the vessel.
- Stage 2, Call and Response: charge, then answer the next active sanctuary cue.
- Reward: healing; overheal becomes Guard; success also grants a modest combat
  boost and boss Break.
- Art: eight-state Resonance Vessel and a dedicated Sanctuary prop atlas.

Exit: the mechanic provides survivability through deliberate positioning.

### Stage 5 — Disco implementation

- Stage 1, Spotlight Flow: keep contact with the moving spotlight as it fills.
- Stage 2, Prism Relay: preserve flow while transferring between linked prisms.
- Reward: strongest cadence increase, plus damage and boss Break.
- Art: eight-state Prism Flow device and a dedicated Prism Palace prop atlas.

Exit: movement continuity has an immediate offensive payoff.

### Stage 6 — Jazz implementation

- Stage 1, Phrase Landing: enter on the active chord window.
- Stage 2, Changes: adapt to faster changing destinations and narrower phrasing.
- Reward: strong damage and cadence with a shorter, more technical window.
- Art: eight-state Changes Conductor and a dedicated midnight rooftop prop atlas.

Exit: Jazz rewards anticipation and adaptation rather than passive occupancy.

### Stage 7 — Encore and boss Break

- A configured chain threshold triggers Encore for a bounded duration.
- Encore uses the seventh animation state and clear HUD feedback.
- Each mechanic success adds Break progress to the current final boss.
- Reaching the Break threshold exposes the boss core and increases damage taken
  for a short window, creating the high-value thrill target.

Exit: mechanic mastery creates a meaningful boss damage opportunity.

### Stage 8 — Boss combat overhaul

- Increase boss health, attack range, damage pressure, and late-stage projectile
  speed while retaining difficulty multipliers.
- Apply 90–96 percent knockback resistance, cap displacement per hit, and prevent
  displacement during attack wind-up.
- Split health into three phases; lower phases reduce attack intervals and add
  projectile count and speed.
- Rotate resonance pulse, aimed fan, radial static wave, and cross-wave patterns.
- Mark selected projectiles as heavy; heavy shots require three cancellation hits.
- Render range as a low-alpha outline and a thin screen-edge warning only.

Exit: strong builds shorten fights but cannot permanently shove or suppress bosses.

### Stage 9 — Art production and animation

- Use the approved high-resolution GPT image workflow with existing atlases as
  direct style references.
- Preserve untouched generation sources in a dated source-candidate folder.
- Remove chroma backgrounds into transparent runtime PNG atlases.
- Slice mechanic atlases into named individual state sprites.
- Animate mechanic devices through semantic states and apply subtle deterministic
  Stage 2 prop motion; disable the added motion when reduced motion is enabled.
- Verify dimensions, alpha, cell isolation, small-scale readability, and absence
  of text/watermarks.

Exit: 8 source sheets, 8 transparent runtime atlases, and 32 individual mechanic
state sprites are validated and integrated.

### Stage 10 — Verification

- Run unit, content, full-run simulation, lint, asset reference, and release tests.
- Add regression coverage for HUD clearance, Stage 2 atlas selection, Encore,
  Soul Guard overflow, heavy projectile cancellation, boss anchoring, resistance,
  phase escalation, and pattern rotation.
- Perform a boot smoke test and targeted World Tour runtime checks.
- Inspect representative generated art and package contents.

Exit: all automated gates are green and manual limitations are reported explicitly.

### Stage 11 — Version and distribution

- Set every authoritative version surface to `0.9.0`.
- Update release notes, changelog, build metadata, landing downloads, and package
  labels together.
- Build the loose play payload, `.love`, macOS, Windows, and any repository-owned
  supported packages using the canonical scripts.
- Verify embedded version metadata and compare payload manifests.

Exit: all generated deliverables contain the same tested source and version.

### Stage 12 — Publish and live verification

- Commit only the isolated v0.9.0 scope.
- Push `codex/world-overhaul-v090` to GitHub.
- Create the v0.9.0 GitHub release and attach verified packages.
- Upload the release/download payload to the configured FTP destination.
- Verify public pages, download URLs, checksums, file sizes, and displayed version.
- Refresh the project handover with exact committed, pushed, released, deployed,
  and public-live evidence.

Exit: GitHub and FTP surfaces both serve the verified v0.9.0 payload.

## Rollback boundaries

- Source rollback: revert the release commit; stable IDs mean saves remain usable.
- Art rollback: point Stage 2 atlas IDs back to the original world atlases.
- Mechanic rollback: the compatibility module can restore the prior shared pad
  entry point without touching call sites.
- Deployment rollback: retain prior v0.8.5 packages and manifests until v0.9.0
  public checks pass.

## Release evidence checklist

- Commit SHA and pushed branch.
- Tag and GitHub release URL.
- Test and lint totals.
- Package names, sizes, and SHA-256 values.
- FTP destination and upload verification.
- Public download response status, size, and checksum parity.
- Remaining manual QA, if any, called out separately from automated completion.
