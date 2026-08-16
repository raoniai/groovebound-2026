## Groove Bound v0.9.6

This release makes fresh World Tour entries slightly more approachable and
removes the detour after losing a selected world.

- Softens the existing fresh-world opening assist for enemy health, damage,
  movement speed, and spawn pressure.
- Blends the assist smoothly back to the full authored difficulty by 150
  seconds or equivalent early-level progress, leaving carried builds and later
  escalation unchanged.
- Adds a primary retry action after a World Tour defeat that immediately
  restarts the same world with the same character and original starting setup.
- Prevents upgrades earned during the failed attempt from carrying into the
  retry.
- Adds a separate Return to World Menu action while retaining Return to Title.
- Preserves stable world IDs, save compatibility, deterministic run ownership,
  World Tour unlocks, records, grades, and victory progression.
