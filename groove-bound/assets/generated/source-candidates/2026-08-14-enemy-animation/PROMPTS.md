# Enemy animation generation prompts

## Shared specification

- Use case: `stylized-concept`.
- Asset type: non-runtime game sprite animation source atlas.
- Preserve the exact reference enemy identities, materials, palette,
  proportions, detailed retro pixel-art rendering, dark outlines, and
  front/three-quarter camera.
- Produce coherent loop frames with constant scale and feet/hover baseline.
- Use one uniform removable chroma background with no shadows, gradients,
  floor, text, labels, borders, grid lines, watermark, extra characters,
  detached fragments, cropping, or cross-cell effects.
- Backbeat uses `#ff00ff` because Feedback Phantom is green. Funk, Soul,
  Disco, Orbit revision 2, and Jazz revision 2 use `#00ff00`.

## Backbeat Streets

Reference: `assets/generated/enemy-variants-atlas.png`

Layout: strict 4x6; rows 1-3 animate source row 1 and rows 4-6 animate source
row 2. Motions: Monotone lurch; Tempo Leech leg cycle; Metronome Guardian
armoured march and pendulum motion; Static Baron planted speaker/antenna pulse;
Syncopation Skitter leg cycle; Feedback Phantom float/tendril undulation; Bass
Brute heavy speaker-body stomp; Noise Turret planted dish scan/recoil.

## Orbit Line

Reference: `assets/generated/campaign/stage2-enemies-atlas.png`

Layout: strict 4x6. Motions: Vinyl Drone hover and turntable/claw cycle;
Trumpet Ray leg cycle and brass recoil; Drum Wheel rolling stomp; Theremin Jelly
float/tentacle curl; Amp Hound quadruped walk; Keyboard Centipede travelling leg
wave; Turntable Sentinel heavy advance/platter/dish motion; Grand Orchestrator
weight shift, cymbal arms, and speaker pulse. Revision 2 changed only the key to
green and explicitly preserved violet/magenta illumination.

## Funk World

Reference: `assets/generated/campaign/funk-enemies-atlas.png`

Layout: strict 4x6. Motions: Pocket Gremlin sneaker walk; Slapback Hound
quadruped walk; Groove Guard speaker-body march; Talkbox Oracle float/keyboard
and hose pulse; Boogie Tank spider-leg cycle; Funkadelic Wasp wingbeat;
Mothership of Funk hover/piano-ring motion; Pocket Phantom smoky sway.

## Soul World

Reference: `assets/generated/campaign/soul-enemies-atlas.png`

Layout: strict 4x6. Motions: Choir Automaton step and microphone sway; String
Sentinel leg/bow cycle; Organ Walker cathedral march; Harmony Linker paired-mask
float; Gospel Moth wingbeat; Velvet Knight shield/staff march; Organ Colossus
organ-leg stomp; Velvet Titan heavy robe/horn-speaker pulse.

## Disco World

Reference: `assets/generated/campaign/disco-enemies-atlas.png`

Layout: strict 4x6. Motions: Prism Roller skating stride; Mirror Drone
rotor/hover; Laser Fan opening pulse; Reflection Twin opposing synchronized
weight shift; Platform Pouncer lunge; Glitter Guard shield march; Laser
Conductor planted baton sweep; Prism Monarch floating facet/speaker pulse.

## Jazz World

Reference: `assets/generated/campaign/jazz-enemies-atlas.png`

Final layout: strict 4x8, one enemy per row and four frames left to right in
row-major source order. Motions: Syncopated Imp jaunty drumstick step; Blue Note
Bat musical wingbeat; Walking Bass Bot walk/string flex; Scat Cannon leg/recoil
cycle; Bebop Behemoth drummer march; Brushfire Skitter leg/brush ripple; Brass
Regent saxophone step/cape movement; Midnight Maestro floating baton/keyboard
conducting cycle. Revision 2 changed the key to green and explicitly preserved
all violet/magenta accents.

