# Admin Controls

The visual admin dashboard is a development-only tab inside **Settings**, or it
can be opened directly with **F1** from the title screen, an active run, or the
pause screen. Public-facing title and pause menus no longer expose separate
Admin or Arsenal entries.

Controls are segmented into Overview, Simulation, Run & Stages, Player,
Combat, Bullets, Enemies, Rewards, and Groove. Each section has a consistent vector icon,
accent, bounded value bar, formatted current value, and explicit −/+ controls.

## Input

| Action | Keyboard | Gamepad | Mouse |
|---|---|---|---|
| Open/close | F1 / Escape | Options/Start or B closes | Menu/Close button |
| Change section | `[` / `]` | Left/Right shoulder | Select sidebar section |
| Select | Up/Down or W/S | D-pad Up/Down | Hover row |
| Decrease/increase | Left/Right or A/D | D-pad Left/Right | − / + |
| Toggle boolean | Enter/Space | A | − / + |
| Reset selected | Backspace | Y | — |
| Reset all | Delete | — | Reset all button |
| Open Arsenal Database | F2 | — | Arsenal Database button |

Opening the panel pushes a modal state, so the run beneath it stops updating.
Menu input itself is never time-scaled.
Mirrored controller/keyboard direction events are deduplicated before they
reach this screen, so each D-pad press changes one row or value only once.

## Safety model

- Every control is registered in `src/config/admin_controls.lua`.
- `src/debug/tuning.lua` rejects unknown IDs and wrong value types.
- Values snap to declared steps and clamp to declared bounds.
- Gameplay systems receive the tuning service; they do not read UI labels.
- Public release packaging must set `settings.debug.admin.enabled = false`.
- Entity/projectile caps remain enforced even when multipliers are high.

## Connection status

The following controls have live runtime consumers:

- simulation speed;
- 5x test mode, which simultaneously multiplies player movement speed, weapon
  damage, XP gain, gem attraction radius, and gem pull speed;
- independent Stage 1 and Stage 2 duration from 60 to 1,200 seconds, with a
  three-minute default for each stage;
- campaign difficulty escalation;
- player speed and invincibility;
- weapon fire-rate and damage multipliers;
- hit knockback;
- projectile speed, extra bullets per shot, and maximum active bullets;
- enemy speed, damage, spawn-rate multiplier, and maximum active enemies;
- XP multiplier and pickup radius;
- Show evolution needs: displays or hides paired-support recipes and exact
  missing rank/support requirements in the pause-menu evolution guide.
- Allow rank-1 evolution: permits only the explicit Admin shortcut; it never
  changes normal rank-10 fusion eligibility.

The BPM override is registered and bounded but is not connected yet because
the BeatClock does not exist.

## Active-run tools

When opened over a run, the panel adds:

| Tool | Key | Behavior |
|---|---|---|
| Grant Level | G | Grants exactly enough XP for the next queued card choice |
| Prepare Evolution | E | Completes an owned weapon's rank/support requirements so its fusion is ready for a chest |
| Rank-1 Evolve | R | Replaces an owned base weapon with its evolved form only when **Allow rank-1 evolution** is enabled |
| Spawn Boss | B | Spawns the current stage's final boss once; duplicate claims are refused |
| Clear Stage | N | Defeats the current final boss and follows the real transition/victory path |

The normal evolution tool still passes through stable-ID eligibility and the
inventory/support/runtime transaction. The Admin bypass is visually and
functionally separate, disabled by default, and cannot lower the requirements
used by the chest reward resolver; ordinary level-up offers exclude evolutions.

## Evolution guidance toggle

Open **Rewards** and toggle **Show evolution needs**:

- **ON** (default): weapon/support cards show their fusion pairing, and the
  pause screen lists the closest owned evolution paths with exact missing
  rank or support requirements.
- **OFF**: hides the guide and recipe hints without changing eligibility,
  randomization, inventory, or fusion behavior.

“Registered” must never be reported as “connected.” A control is connected
only when a system consumes it and an integration test verifies the effect.
