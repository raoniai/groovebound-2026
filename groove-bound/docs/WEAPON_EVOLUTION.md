# Weapon Evolution Contract

## Authoritative state

- `WeaponInventory` owns weapon IDs, levels, slots, and evolution provenance.
- `WeaponRuntime` owns the emitters that are actively firing.
- `WeaponEvolution` is the only system allowed to transform one weapon into
  another.
- Evolution recipes are data in `src/content/evolutions.lua`.

## Eligibility

An evolution is legal only when all conditions are true:

1. The recipe ID exists.
2. The reward source supplies the exact declared trigger.
3. The base weapon is actually in the inventory.
4. That exact weapon instance meets the required level.
5. Every passive requirement is owned at the required level.
6. The result weapon is not already owned.
7. The weapon runtime exactly matches the inventory before mutation.

Names and descriptions never participate in these checks.

## Transaction

1. Snapshot inventory, passive state, and active emitters.
2. Replace the base weapon in its existing slot.
3. Record `evolved_from` and `evolution_id`.
4. Consume passive requirements only if the recipe explicitly requests it.
5. Replace the emitter in the same slot.
6. Assert inventory/runtime identity, level, slot, and revision equality.
7. Roll everything back if any step fails.

## Projectiles already in flight

Projectile stats are copied when the projectile is created:

- source weapon ID and level;
- damage;
- speed;
- count;
- size;
- lifetime;
- spread;
- pierce.

Evolution does not mutate existing projectiles. Shots created after the
transaction use the evolved emitter and evolved stats.

## Initial Studio/Live branch

Both initial recipes require:

- Kazoo Pistol rank 10;
- Breath Control rank 1 or higher;
- a `resolve_reward` trigger earned from the miniboss.

The reward presents two exact stable-ID results:

- `kazoo_studio` → Brass Barrage, a reliable piercing three-note burst;
- `kazoo_live` → Improvised Solo, a more volatile groove-dependent phrase.

The chosen result replaces the same inventory slot at rank 1. Display names
can change later without changing eligibility.

## Integrated and verified

- Normal level-up cards cannot bypass the evolution trigger.
- The Metronome Guardian grants one Resolve token and cannot pay twice.
- Resolve remains banked until the Kazoo/passive conditions are valid.
- Studio and Live cards are derived from the same legal loadout.
- The selected result updates inventory, HUD, results and active emitter.
- Existing projectiles keep their original snapshot.
- Result snapshots serialize stable IDs and evolution provenance.
- Seeded offers are deterministic and reject capped, duplicate or slot-invalid
  candidates.
- The admin preparation tool constructs a legal state but still uses the same
  two-branch menu and normal transaction.
