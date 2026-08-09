# Content and balance contracts

## Definition sources

- Characters: `src/content/characters.lua`
- Weapons: `src/content/weapons.lua`
- Supports: `src/content/passives.lua`
- Evolutions: `src/content/evolutions.lua`
- Enemies: `src/content/enemies.lua`
- Stages: `src/content/stages.lua`
- Waves: `src/content/waves.lua` and `stage2_waves.lua`
- Validation: `src/content/validate.lua`

## Required cross-checks

- Stable ID is unique and referenced consistently.
- Runtime weapon catalog supports the definition.
- Evolution base, support, and result all exist.
- Atlas mapping and UI label exist where required.
- Rank, capacity, and reward rules keep the item obtainable.
- Documentation describes current behavior rather than an earlier design.

## Balance evidence

Collect seed, character, duration, difficulty settings, level curve, offer mix, fusion timing, damage share, enemy pressure, boss timing, and result. Use a seed matrix for regression confidence and a real playthrough for feel.
