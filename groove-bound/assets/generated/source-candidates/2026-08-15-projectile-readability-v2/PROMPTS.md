# Projectile sprite prompts

## Shared production prompt

Production note: the first two attempts at direct transparent output produced
an RGB checkerboard. The accepted generation calls therefore replaced
“genuinely transparent background” with “one perfectly uniform flat chroma
green `#00ff00` background, with no shadows or green inside the effect.” The
saved `chroma-sources/` files are untouched outputs; transparency was created
afterward with the documented soft-matte/despill process.

Use case: stylized-concept

Asset type: transparent 2D game projectile animation sheet for Groove Bound

Create one polished 4-column by 2-row sprite sheet containing exactly eight
chronological animation frames of the named projectile. One projectile or
effect core only in every frame. Target canvas 2048 x 1024 RGBA with eight
equal 512 x 512 cells. Genuinely transparent background. Keep every state
centred in its own cell with generous clear gutters and no cross-cell effects.

The source art must be large enough to render at native scale or smaller next
to a game character. Use a clean bright urban-supernatural music aesthetic,
crisp illustrated/pixel-hybrid edges, one dominant color, soft neutral-white
highlights, translucent interiors, open negative space, sparse particles, and
restrained glow. Make the silhouette simpler and less solid than the previous
version. No weapon object, character, enemy, environment, UI, labels, borders,
grid lines, checkerboard, opaque backdrop, or watermark.

The eight frames must visibly change shape and energy flow rather than merely
scale the same drawing. Never include multiple shots, a baked volley, fan,
radial group, orbit group, or several target strikes. Multi-shot behavior will
later duplicate this one sprite with subtle deterministic timing offsets.

## Per-projectile prompts

Each generated call appends one of the following identity blocks to the shared
production prompt.

| Stable ID | Family | Identity and eight-state direction |
|---|---|---|
| `kazoo_pistol` | linear | One slim golden buzzing sound dart: tiny seed, ignition notch, two aerodynamic vibration shapes, bright peak, split edge, dissolve, two-dot remnant. |
| `bass_drop` | lobbed bomb | One violet bass charge: seed, two arcing flight states, impact compression, translucent low-frequency bloom, open shock ring, sparse falling fragments, remnant. |
| `cymbal_slicer` | boomerang | One amber crescent cutter: edge glint, launch, opening crescent, stable spin, bright cutting peak, chipped return, thinning arc, remnant. |
| `feedback_loop` | storm | One cyan feedback lightning strike: target spark, descending filament, forked contact, stable strike, travelling pulse variation, broken branches, fading filament, remnant. |
| `drum_circle` | area effect | One mint rhythm pulse around an empty centre: faint beat mark, partial arcs, opening ring, offset pulse ring, peak ring with large gaps, broken arcs, fading arcs, remnant. |
| `trumpet_burst` | beam | One warm red-orange pressure beam: emitter glint, short flare, half beam, full tapered beam, travelling compression pulse, fractured beam, retraction, afterglow. |
| `vinyl_scratch` | boomerang | One violet record-scratch crescent: needle glint, launch slash, hooked crescent, rotating crescent, bright groove edge, fragmented return, thin echo curve, remnant. |
| `synth_wave` | wave | One cyan waveform segment: quiet line, rising oscillation, formed wave, asymmetric motion variation, airy peak wave, broken frequencies, fading waveform, remnant. |
| `triangle_tracer` | linear | One silver-cyan triangular ping: pinpoint, triangular ignition, slim tracer, alternate vibrating tracer, bright hollow triangle peak, split corners, fading line, remnant. |
| `cello_lance` | beam | One narrow amber string-energy lance: bow glint, short line, half lance, full needle beam, vibrating peak with a clear end cap, snapped segments, retracting string, afterglow. |
| `maraca_orbit` | orbital | One mint maraca-like energy mote: seed, shake tilt, orbit-ready mote, alternate spin, bright hollow peak, shell split, fading curved trail, remnant. |
| `tuning_fork` | storm | One blue tuned lightning strike: tuning spark, twin filament start that joins one strike, forked contact, stable strike, resonance pulse, branch breakup, fading filament, remnant. |
| `keytar_chord` | wave | One indigo chord-wave tile with open centre: key glint, thin chord line, formed translucent tile, shifted harmonic variation, luminous peak edge, separated bars, fade, remnant. |
| `bell_tower` | lobbed bomb | One bronze toll charge: small bell-tone seed, two heavy flight states, impact, translucent bronze bloom, open toll ring, sparse fragments, remnant. |
| `tape_repeater` | deployable | One mint echo node: tape-speck seed, landing cue, compact node, first open pulse, alternate second pulse, loosening loop, fading node, remnant. |
| `laser_harp` | beam | One crafted cyan laser string, never a fan: emitter glint, short ignition string, half-length ray, full thin ray with authored end cap, subtle travelling harmonic pulse, segmented breakup, graceful retraction, faint afterglow. |
| `brass_barrage` | linear | One polished gold brass dart, never three darts: seed, ignition, formed dart, alternate vibrating dart, brilliant hollow peak, split brass edge, dissolve, remnant. |
| `improvised_solo` | storm | One mint-electric solo strike: target spark, descending improvisational filament, asymmetric fork contact, stable strike, rhythmic peak variation, loose branch breakup, fading line, remnant. |
| `subwoofer_supernova` | area effect | One purple supernova pulse around empty centre: seed, partial bass arcs, transparent expansion, alternate ripple, large open peak ring, broken ring, fading arcs, remnant. |
| `orbital_ovation` | orbital | One gold double-edged crescent object, not an orbit group: glint, launch curl, formed crescent, spin variation, bright open peak, separated edges, fading trail, remnant. |
| `thunderhead_ensemble` | storm | One red-gold thunder strike, not twelve strikes: target spark, descending bolt, grounded fork, stable strike, rolling peak pulse, branch breakup, fading filament, remnant. |
| `golden_fortissimo` | beam | One wide but airy golden pressure beam: emitter burst, short flare, half beam, full translucent tapered beam, travelling forte pulse, fractured gaps, retraction, soft afterglow. |
| `gravity_groove` | deployable | One violet gravity node: pinprick, landing spiral, compact hollow well, first open distortion ring, offset pulse variation, broken orbit line, fading node, remnant. |
| `neon_crescendo` | wave | One mint-cyan crescendo wave segment: quiet line, rising bar, formed translucent wave, taller asymmetric variation, airy peak, separated frequency bars, fade, remnant. |
| `prismatic_triangle` | linear | One prismatic hollow triangular dart, never three lanes: seed, refracted ignition, formed tracer, shifted spectral edge, bright peak, split prism corners, dissolve, remnant. |
| `velvet_impaler` | beam | One long narrow blue-violet velvet beam: emitter glint, short lance, half beam, full authored spear with pointed end cap, soft travelling pulse, clean fracture, retraction, afterglow. |
| `carnival_superorbit` | orbital | One pink-gold carnival crescent object, not a halo: seed, festive tilt, formed open crescent, spin variation, bright ribbon peak, separated ribbon edges, fading curve, remnant. |
| `resonance_rupture` | storm | One pale-blue resonance strike, not ten points: target mark, descending filament, contact fork, stable strike, tuned pulse variation, snapped harmonic branches, fade, remnant. |
| `stadium_keytar` | wave | One violet stadium chord column: faint bar, rising outline, translucent formed column, offset harmonic variation, luminous open peak, separated bars, fade, remnant. |
| `cathedral_overdrive` | lobbed bomb | One gold cathedral toll charge: sacred-tone seed, two weighty flight states, impact, translucent radial bloom, large open ring with architectural points, sparse fragments, remnant. |
| `infinite_mixtape` | deployable | One green-cyan infinite echo node: tape glint, landing loop, compact node, open first repeat, offset second repeat, loosened loop, fading node, remnant. |
| `aurora_harp` | beam | One crafted aurora laser string, never a fan: cyan-violet emitter glint, short ignition, half ray, full thin aurora ray with end cap, travelling color pulse, elegant segmented breakup, retraction, faint afterglow. |
