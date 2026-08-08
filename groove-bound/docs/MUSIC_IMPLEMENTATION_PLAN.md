# Groove Bound — Music Implementation Plan

## Outcome

Implement the selected soundtrack throughout the complete Groove Bound campaign,
one cue at a time, with deterministic routing, seamless 32-beat loops, persistent
volume control, clean modal behaviour, and verified packaging.

This is an implementation runbook. It does not authorize choosing final creative
takes on the user's behalf, regenerating approved music, changing combat timing,
or claiming BeatClock integration before BeatClock exists.

## Execution status — 2026-08-08

- Cues 01–30 and the Cue 27 stage-clear derivative are locally integrated.
- All promoted runtime files pass the automated audio acceptance checks recorded
  in `docs/audio/MUSIC_QA_LOG.md`.
- The user approved saved takes and waived the unavailable WAV-master rule.
- Cue 04 uses its already-generated alternate because its first take failed the
  safe tempo-correction gate.
- Automated routing, catalog, director, context, gameplay, lint, and package
  checks are tracked separately from manual listening and campaign playthrough.
- BeatClock remains explicitly out of scope; gameplay timing is unchanged.

## Baseline before implementation

- Canonical runtime: `groove-bound/`.
- Current campaign flow: Title → Prologue → Character Selection → Character
  Intro → Stage 1 → inter-stage cutscene → Stage 2 → ending → Results.
- Runtime audio currently contains four static SFX only: projectile, XP,
  enemy death, and level up.
- `master_volume`, `music_volume`, and `sfx_volume` already exist in the saved
  Options profile, but only master × SFX is currently applied.
- There is no music catalog, music director, adaptive music router, or BeatClock.
- Gameplay waves are scaled when Admin changes stage duration. Music routing must
  therefore use live wave/stage state, not hard-coded elapsed seconds.
- Pause, level-up, results, Admin, Arsenal, and Options are stack-based screens.
- The 60 generation prompts and two creative routes for each cue live in
  `docs/MUSIC_GENERATION_PROMPTS.md`.

## Delivery states

Use these exact status labels while executing this plan:

1. **Candidate received** — an audio file exists but has not passed checks.
2. **Audio validated** — format, duration, loop, loudness, and provenance pass.
3. **Locally integrated** — the cue is routed in code and its automated tests pass.
4. **Manually verified** — the cue was heard in the correct runtime state and its
   entry, loop, exit, and volume were checked.
5. **Campaign verified** — both complete character paths and all exceptional
   transitions pass.
6. **Packaged** — the `.love` archive contains every runtime track and excludes
   masters/source candidates.
7. **Committed / pushed / merged** — report each Git state separately and only
   after direct verification.

Never use “done” to collapse these states.

## Protected scope and stop rules

The implementation agent must preserve:

- existing SFX behaviour and SFX volume control;
- deterministic combat, RNG, waves, progression, and stage duration scaling;
- automatic and manual cutscene timing, previous-slide navigation, and skipping;
- Joe and Lyra's existing gameplay differences;
- the current state-machine stack and modal pause behaviour;
- accessibility settings and debug/Admin controls;
- existing user changes in the working tree.

Stop and report a blocker when:

- a cue file is missing, corrupt, clipped, voiced, licensed ambiguously, or not
  approved for local promotion;
- a supposed 32-beat loop cannot loop cleanly after editing;
- the cue's rendered BPM or length does not match its manifest;
- an implementation change would alter simulation timing or require inventing
  BeatClock behaviour;
- the worktree contains overlapping user edits that cannot be preserved;
- the build plays two unintended full music cues simultaneously;
- package inspection shows source WAVs or generator source candidates shipping.

Do not substitute unrelated music, use the legacy SFX as music, or silently
repair a rejected creative take.

## Required audio acceptance contract

Before a cue enters runtime code, require:

- one user-selected route/take for the cue, identified by stable cue ID;
- instrumental-only content: no vocals, spoken words, choir, chanting, vocal
  chops, vocoder, or recognisable voice textures;
- master WAV at 48 kHz, 24-bit, stereo;
- runtime OGG Vorbis export at 48 kHz stereo;
- exactly 32 musical beats for looping cues, normally 8 bars of 4/4;
- rendered duration consistent with `1920 / BPM` seconds, within the declared
  export tolerance;
- no leading encoder silence, trailing silence, fade-out, click, rhythmic gap,
  or reverb jump at beat 32 → beat 1;
- integrated loudness target of approximately -18 LUFS for gameplay/menu cues,
  with dialogue cues reduced or ducked further in runtime;
- true peak no higher than -1 dBTP;
- no uncontrolled sub-bass or constant midrange density that masks combat SFX;
- provenance: generator/tool, model/version, date, prompt route, seed if
  available, take number, edits, rights/licence note, and approver.

One-shot derivatives are allowed only where this plan explicitly calls for one.
They must be cut from the accepted 32-beat master and recorded in the manifest.

## Canonical asset layout

```text
assets/music/
  01_title.ogg
  02_prologue_city.ogg
  ...
  30_ending_teaser.ogg
  stage_clear_sting.ogg

assets/generated/source-candidates/music/
  <48 kHz WAV masters and unapproved takes>

docs/audio/
  MUSIC_MANIFEST.md
  MUSIC_QA_LOG.md
```

Only approved runtime OGG files belong in `assets/music/`. Masters, alternate
takes, and generator exports stay under source candidates and must not ship.

## Technical architecture to implement first

### 1. Music catalog

Add `src/content/music.lua` as the single data source for music metadata. Every
record should contain:

```lua
{
  id = "title",
  path = "assets/music/01_title.ogg",
  bpm = 112,
  beats = 32,
  meter = 4,
  loop = true,
  gain = 1.0,
  transition = "crossfade",
}
```

Validate stable IDs, unique paths, positive BPM, exactly 32 beats for loop cues,
valid gains, declared transition modes, and file existence at boot. Do not place
screen logic or gameplay conditions in the catalog.

### 2. Pure music router

Add `src/audio/music_router.lua`. It receives a plain context snapshot and
returns a declarative music intent:

```lua
{
  cue = "stage1_opening",
  overlay = nil,
  duck_db = 0,
  preserve_underlay = false,
}
```

The router must be engine-independent and fully headless-testable. Priority from
highest to lowest:

1. ending, victory, or defeat state;
2. explicit cutscene cue;
3. Admin, Arsenal, level-up/evolution, or pause modal;
4. final boss phase;
5. miniboss;
6. low-health overlay;
7. stage wave/intensity cue;
8. character select;
9. title/fallback.

The low-health layer is additive; it must not replace a boss or gameplay cue.

### 3. App-scoped music director

Add `src/audio/music_director.lua` and create it once during `love.load`. The
director owns music playback for the whole application; screens must not create
or directly control `love.audio.Source` objects.

Required behaviour:

- use `love.audio.newSource(path, "stream")` for full music tracks;
- keep at most two full cues active during a crossfade, plus one approved danger
  overlay;
- apply `master_volume × music_volume × cue_gain` independently from SFX;
- ignore repeated requests for the already-current cue;
- crossfade normal screen changes in roughly 250–500 ms;
- allow musical/bar-aligned changes for non-urgent wave escalation;
- change immediately for boss arrival, defeat, or cutscene skip;
- call `setLooping(true)` only on validated loop cues;
- preserve the underlying playback cursor when pause, Level Up, Admin, or Arsenal
  temporarily replaces gameplay music;
- resume the preserved cue from its prior cursor when the modal closes;
- stop and release run music when switching to Title or Character Selection;
- avoid restarting music when a cutscene advances between slides that share a cue;
- expose current cue, overlay, gain, playback time, and transition state to debug
  logs without adding them permanently to the normal HUD;
- pause/resume all music safely on window focus loss/gain;
- fail visibly in development if a catalogued runtime file is absent.

Update the director once per real frame from `love.update`, after the active
screen has updated. Do not scale music time with Admin's simulation time scale.

### 4. State snapshot adapter

Add one small adapter that reads the current top screen and safe, public runtime
snapshots. Do not scatter `play()` calls across every screen.

The adapter needs:

- top screen kind;
- cutscene scene ID and slide index;
- selected character where relevant;
- stage index and active wave index;
- live miniboss/final-boss ID and HP fraction;
- whether the Grand Orchestrator final phase has latched;
- player HP fraction;
- whether the Level Up offer contains an evolution;
- run outcome;
- modal origin and the cue/cursor to preserve.

Expose `active_wave_index` through the SpawnDirector/Combat snapshot when a wave
activates. Do not infer waves from fixed seconds because Admin rescales them.
Expose boss state through CombatSystem rather than rescanning every entity in
the audio layer.

### 5. Options integration

When Master or Music volume changes, update music gain live and save it. When SFX
changes, preserve the current SFX path. Verify all combinations:

- Master 0 mutes music and SFX.
- Music 0 mutes only music.
- SFX 0 mutes only SFX.
- Restoring any value takes effect without restarting the cue.
- Saved settings survive relaunch.

### 6. BeatClock boundary

This plan makes the music metadata future-ready but does not implement gameplay
BeatClock. Combat, projectiles, enemies, XP, and RNG remain independent from
audio playback. Bar-aligned audio transitions may use the current source cursor,
but no gameplay reward or penalty may depend on it in this work.

## One-cue implementation protocol

The agent must execute this protocol for cue 01, then repeat it for cue 02, and
so on. Do not bulk-wire several cues and test them later.

1. **Resolve candidate:** identify the chosen route/take and provenance.
2. **Validate audio:** confirm format, BPM, 32 beats, loop seam, loudness, peaks,
   and absence of vocals.
3. **Promote asset:** copy only the approved OGG into `assets/music/` and add its
   catalog/manifest record.
4. **Write failing routing test:** prove the exact game snapshot should request
   this cue and neighbouring snapshots should not.
5. **Wire the trigger:** make the smallest code change needed for the cue.
6. **Run focused tests:** music catalog, router, director, and affected screen or
   combat tests.
7. **Listen in runtime:** verify entry, at least three complete loops, exit,
   volume, and SFX/dialogue clarity.
8. **Record evidence:** append result, file hash, tested path, and any limitation
   to `docs/audio/MUSIC_QA_LOG.md` before moving to the next cue.

If any check fails, keep the cue at the previous status and do not start the next
one.

## Sequential cue map

The selected A/B route from `MUSIC_GENERATION_PROMPTS.md` maps to these stable
runtime cues.

| Order | Cue ID | Exact runtime trigger | Exit / restoration | Cue-specific check |
|---:|---|---|---|---|
| 01 | `title` | Title screen becomes top-level state | Crossfade on New Game; preserve under temporary Title modals | Relaunch, return from Results, and Quit-to-Title all start exactly one instance |
| 02 | `prologue_city` | Prologue slide 1 | Switch on slide 2 or cutscene skip | Manual back from slide 2 restores it without duplicate playback |
| 03 | `prologue_break` | Prologue slide 2 | Switch on slide 3, back to slide 1, or skip | Reversed/glitch cue never masks dialogue reveal |
| 04 | `prologue_resolve` | Prologue slides 3–4 | Crossfade to Character Select on completion/skip | Advancing slide 3→4 does not restart the shared cue |
| 05 | `character_select` | Character Selection screen | Switch to chosen intro; back returns to Title | Moving selection between Joe/Lyra does not restart music |
| 06 | `joe_intro` | Scene ID `joe_intro`, all slides | Switch to Stage 1 | Manual previous/advance and auto timing remain correct |
| 07 | `lyra_intro` | Scene ID `lyra_intro`, all slides | Switch to Stage 1 | Same checks as Joe; no Joe cue can leak into this route |
| 08 | `stage1_opening` | Stage 1 active waves 1–2 with no boss alive | Bar-aligned move to pressure cue; modal preserves cursor | Verify both characters and Admin-shortened stage timing |
| 09 | `stage1_pressure` | Stage 1 active waves 3–5 with no boss alive | Miniboss overrides; resume current base cue after boss death | Wave changes use live index, not elapsed seconds |
| 10 | `metronome_guardian` | Metronome Guardian exists alive | Return to Stage 1 cue appropriate to current wave | Boss spawn is immediate; death transition does not overlap boss cue |
| 11 | `stage1_overload` | Stage 1 active wave 6 onward, before Static Baron override | Final boss overrides | Dense combat SFX remain clearer than melody and bass |
| 12 | `static_baron` | Static Baron exists alive | Stage-clear sting, then First Press cutscene | Admin Spawn Boss and normal wave spawn behave identically |
| 13 | `first_press` | `stage2_transition` slides 1–2 | Switch on slide 3, back, or skip | Slide navigation produces correct reversible cue changes |
| 14 | `dead_line_recovery` | `stage2_transition` slide 3 | Switch to Stage 2 arrival on completion | Build carryover and 25% HP recovery remain unchanged |
| 15 | `stage2_arrival` | Stage 2 active waves 1–3 with no boss alive | Bar-aligned move to escalation cue | Stage begins only after transition finishes/skips |
| 16 | `stage2_escalation` | Stage 2 active waves 4–6 with no boss alive | Sentinel overrides; resume correct base cue on death | Mixed enemy pressure remains audible and loop is clean |
| 17 | `turntable_sentinel` | Turntable Sentinel exists alive | Return to cue for current active wave | Normal and Admin-driven boss paths both pass |
| 18 | `stage2_overload` | Stage 2 active waves 7–8, before final boss override | Grand Orchestrator overrides | No accidental restart between waves 7 and 8 if same cue remains |
| 19 | `grand_orchestrator_p1` | Grand Orchestrator alive above 45% HP | Latch phase two at or below 45% | Phase one begins immediately and never plays with Sentinel cue |
| 20 | `grand_orchestrator_final` | Grand Orchestrator reaches 45% HP or lower | Remains latched until death; never reverts | Threshold crossing occurs once and does not alter boss gameplay |
| 21 | `level_up` | Level Up modal with no evolution card in the offer | Restore exact underlying cue/cursor on choose, skip, or close | Reroll stays on cue unless it reveals an evolution card |
| 22 | `evolution` | Level Up modal contains an evolution card | Restore underlying cue after selection/skip; optional derived sting on selection | Evolution music cannot continue after the modal closes |
| 23 | `low_health` | Gameplay HP ≤25%, with a tempo-matched overlay available | Fade out only after HP ≥35%, stage change, results, or run exit | Hysteresis prevents rapid toggling; overlay never runs off-beat |
| 24 | `pause` | Pause is the top screen during a run | Resume underlying gameplay/boss cue at preserved cursor | Pause for 30+ seconds, open nested Options, then resume correctly |
| 25 | `arsenal` | Arsenal Database is top screen from Title or Pause | Restore the originating cue/cursor | Test both entry origins and repeated open/close cycles |
| 26 | `admin` | Admin screen is top screen from Title, Pause, or Run | Restore the originating cue/cursor | Admin actions can change stage/boss state; resolve new intent on close |
| 27 | `stage_clear_sting` | Final boss death event in a non-final stage | Play approved 8-beat derivative, then cut cleanly to First Press | Never delay or block the existing transition cutscene |
| 28 | `victory_results` | Victory Results becomes top state after ending cutscene | Switch on character choice or Title | Only begins after the ending scene completes or is skipped |
| 29 | `defeat_results` | Defeat Results becomes top state | Switch on character choice or Title | Run/boss/low-health sources all stop before it begins |
| 30 | `ending_teaser` | Ending scene ID `ending`, all slides | Crossfade to Victory Results on completion/skip | No spoken Grand Conductor audio; dialogue remains intelligible |

## Cue 23 tempo rule

Do not layer one generic rhythmic low-health file over tracks with different BPMs.
Use one of these safe approaches, in priority order:

1. export a danger stem from each accepted gameplay/boss session at the exact
   parent BPM and loop length;
2. render stage-family variants only after all cues in that family share a BPM;
3. use a deliberately non-rhythmic, pulse-free danger texture.

Do not use LÖVE `Source:setPitch` to force tempo matching because it also changes
pitch. If no compatible overlay exists, leave low-health music unintegrated and
report it honestly rather than shipping an off-beat layer.

## Cue 27 derivative rule

The current game moves immediately from Stage 1 boss death into the First Press
cutscene. Do not delay the cutscene to fit a 32-beat victory track. Create an
approved 8-beat `stage_clear_sting.ogg` derivative from cue 27's accepted master,
play it as a non-looping one-shot, and allow cue 13 to replace it immediately.
Record the derivative's source hash and edit in the manifest.

## Transition policy

- **Immediate 250–500 ms crossfade:** screen change, cutscene skip, boss arrival,
  boss phase change, victory, defeat, or return to Title.
- **Next-bar transition:** wave/intensity escalation when no urgent state change
  exists and the outgoing cue metadata is valid.
- **Suspend and restore:** Pause, Level Up, Admin, and Arsenal opened from a run.
- **Duck only:** Options/Controls nested inside another modal; inherit the parent
  cue and reduce it by approximately 3 dB instead of starting another track.
- **Dialogue duck:** reduce cutscene cue approximately 4–6 dB relative to menu
  music, tuned by listening rather than hard-coded per screen.
- **Same cue:** make no transport change.

## Automated checks after every cue

Run the smallest relevant set first, then the full gates for each completed cue
group.

### Required unit tests

- `music_catalog_test.lua`
  - validates every metadata record and stable ID;
  - rejects duplicate IDs/paths and invalid beats/BPM/gain;
  - proves approved runtime files exist in a LÖVE boot check.
- `music_router_test.lua`
  - table-driven test for all 30 cues;
  - verifies priority rules, boss overrides, phase latch, modal origins,
    cutscene slide navigation, evolution offers, and low-health hysteresis.
- `music_director_test.lua`
  - uses fake Source objects;
  - proves idempotent same-cue requests, crossfade limits, loop flags, gain math,
    cursor preservation, focus pause/resume, cleanup, and no leaked sources.
- Update affected campaign, cutscene, options, SpawnDirector, CombatSystem, and
  state-machine tests only where a new public snapshot contract is introduced.

### Full gates

```text
make test
make lint
git diff --check
make package
```

After packaging, inspect the archive rather than trusting build success:

- every `assets/music/*.ogg` runtime file is present;
- no WAV master, alternate take, source candidate, QA log, or prompt document is
  present;
- the archive boots with Music volume at 0%, 50%, and 100%;
- package size increase matches the manifest within an explained tolerance.

## Manual check required for every cue

Automated tests cannot prove musical correctness. For each cue:

1. enter through the normal player path, not only Admin shortcuts;
2. confirm the cue starts in the exact intended state;
3. listen through three beat-32 → beat-1 loops using headphones;
4. listen once on laptop speakers or a small mono speaker;
5. trigger representative projectiles, XP pickups, enemy deaths, and level-up
   SFX over the cue;
6. test Music 0%, 50%, and 100%, plus Master 0%;
7. exit normally and through at least one exceptional path such as Back, Skip,
   Pause, defeat, or Admin Clear Stage;
8. confirm no click, gap, double music, stale cue, dialogue masking, or unwanted
   restart;
9. capture the tested route and result in the QA log.

## Group regression gates

Do not start the next group until the previous group passes as a whole.

### Gate A — Foundation and front end

Cues 01–07. Verify boot, Title modals, prologue auto/manual/back/skip, character
selection, both character intros, and return-to-Title paths.

### Gate B — Stage 1

Cues 08–12 plus cue 27. Run Stage 1 normally once and with Admin-shortened
duration once. Verify wave scaling, miniboss override/resume, Static Baron,
stage-clear sting, SFX clarity, pause, and low health.

### Gate C — Transition and Stage 2

Cues 13–20. Verify reversible slide mapping, cutscene skip, build carryover,
Stage 2 arrival, wave escalation, Sentinel override, Grand Orchestrator phase
latch, and final boss death.

### Gate D — Modals and results

Cues 21–26 and 28–30. Verify normal/evolution offers, reroll changes, pause,
nested Options, Arsenal/Admin from both origins, defeat, ending skip, victory,
character choice, and Title return.

## Final double-check: two complete campaign passes

### Pass 1 — Joe, normal narrative path

- Start from a fresh launch with saved volume settings.
- Let every cutscene auto-advance.
- Play both stages as Joe without Admin-clearing bosses.
- Trigger at least one normal level-up, one evolution offer/selection, low
  health and recovery, Pause → Options → Resume, and Arsenal from Pause.
- Defeat both minibosses and final bosses.
- Let the ending complete automatically and reach Victory Results.
- Return to Title and confirm only the Title cue remains.

### Pass 2 — Lyra, exceptional/control path

- Start New Game, manually advance and go back in the prologue, then skip it.
- Select Lyra and manually advance her intro.
- Use Admin-shortened stage durations, Spawn Boss, and Clear Stage.
- Open/close Admin from Title, Run, and Pause.
- Test evolution-card routing with Prepare Evolution.
- Test the Orbit Line transition with manual back and confirmed skip.
- Cross the Grand Orchestrator 45% threshold and confirm phase two never reverts.
- Perform one deliberate defeat path and one victory path.
- Choose Character from Results, then return to Title.

### Final listening audit

- Compare all selected cues in campaign order at matched perceived loudness.
- Check recurring hero motif and consistent Stage 1/Stage 2 palette.
- Confirm Joe and Lyra intros are distinct but belong to the same soundtrack.
- Confirm every cutscene remains dialogue-first.
- Confirm bosses are more intense than their surrounding wave cues.
- Confirm Results music communicates victory or retry without conflicting with
  the ending teaser.
- Listen for abrupt key/BPM collisions at every transition.

## Performance and resilience checks

- Observe memory across ten cue changes and ten modal open/close cycles; source
  count must remain bounded.
- Verify no new frame-time spike when a streamed cue starts.
- Test window focus loss for at least 30 seconds during gameplay and a cutscene.
- Test relaunch after Music volume was saved at zero.
- Test a missing music file in development: boot must report the exact cue/path.
- Test release package without source candidates present on disk.
- Confirm music does not advance with simulation time scale and does not affect
  deterministic full-run tests.

## Provenance and documentation update

For every accepted cue, add a manifest row with:

| Field | Required value |
|---|---|
| Cue ID | Stable runtime ID |
| Game state | Exact trigger from the cue map |
| Selected route | Prompt A or B |
| Generator/model | Exact tool and version |
| Generated date | ISO date |
| Seed/take | When available |
| Source master | Relative source-candidate path |
| Runtime file | Relative OGG path |
| BPM / beats / meter | Rendered values |
| Duration | Measured seconds |
| Loudness / true peak | Measured values |
| SHA-256 | Master and runtime hashes |
| Editing | Loop, master, derivative, or stem work |
| Rights note | Usage/licensing record |
| Approval | Approver and date |
| QA state | Audio validated / integrated / manually verified |

Update README only after the soundtrack is campaign-verified. Describe the
true state—candidate, integrated, or verified—and do not claim BeatClock or a
final soundtrack release prematurely.

## Completion contract

The music implementation is complete only when:

- all 30 cue IDs are either manually verified or explicitly listed as blocked;
- every accepted loop passes three-loop listening and automated routing tests;
- the two complete campaign passes succeed;
- volume persistence, modal restoration, boss priority, cutscene skip/back, and
  low-health behaviour pass;
- test, lint, diff, and package gates pass;
- the package contents are inspected directly;
- runtime assets and provenance records match by path and hash;
- no source candidates ship;
- the final Git and delivery state is reported precisely.
