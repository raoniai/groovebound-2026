# Weapon and Support Fusion Contract

## Authoritative state

- `WeaponInventory` owns weapon IDs, ranks, capacity, and slots.
- `PassiveInventory` owns support IDs, ranks, capacity, and slots.
- `WeaponRuntime` owns the emitters actively firing.
- `WeaponEvolution` is the only fusion transaction.
- `src/content/evolutions.lua` owns the eight stable-ID recipes.

## Eligibility

A fusion is legal only when:

1. the recipe exists and uses the `level_up` trigger;
2. the exact base weapon is owned at rank 10;
3. the exact paired support is owned at its required rank;
4. the evolved result is not already owned;
5. every active emitter matches weapon inventory slot, ID, rank, and revision.

The HUD checks this contract continuously and emits a five-second
**YOU CAN EVOLVE NOW** notification when a new recipe becomes legal.

## Atomic transaction

Inventory, support inventory, and weapon runtime are snapshotted before
mutation. Fusion replaces the weapon in place, consumes the support, expands
weapon capacity by one up to a six-slot cap, rebuilds support-derived
modifiers, and verifies the new active emitter. Any failure restores all
snapshots.

This means the player loses both original ingredients, gains the stronger
recognizable fusion, receives a free support slot, and gains room to collect
another base weapon.
