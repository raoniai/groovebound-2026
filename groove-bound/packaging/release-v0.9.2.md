## Groove Bound v0.9.2

This release replaces weapon-shaped player shots with a complete projectile
system built for combat readability and long-range protection.

- Adds 32 independent projectile atlases with five genuinely authored stages
  each: charge, formation, peak, breakup, and remnant.
- Adds nine deterministic projectile families: linear, boomerang, bomb, area,
  orbital, beam, scenario storm, wave, and deployable.
- Gives long beams authored origins and endpoints, uniform rendering scale, and
  readable charge and dissipation windows instead of stretched sprites.
- Lengthens recovery for high-power beams, storms, novas, and scenario attacks
  while preserving viable deterministic campaign completion.
- Expands projectile range, blast radius, area radius, beam geometry, orbit
  distance, storm reach, target count, or wave width as weapons rank up.
- Removes the retired shared projectile atlas from runtime and distribution.
