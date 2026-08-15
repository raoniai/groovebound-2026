# Groove Bound World Tour Music Plan

## Generation approval contract

- Suno workspace: `Groove Bound`
- Suno plan: Pro
- Model: `v5.5`
- Mode: Advanced, Instrumental
- Prompt field: Styles only
- Duration: Auto
- Weirdness: 30%
- Style influence: 80%
- Current balance observed before generation: 2,170 credits
- Cost: 28 Create actions, two candidates per action, 280 credits total
- Expected balance after the approved batch: 1,890 credits
- References uploaded: none
- Coherence reference: the existing Groove Bound soundtrack and its shared
  instrumental 32-bit MIDI, urban-supernatural, cosmic-funk identity
- Selection rule: listen to both candidates, promote one take per cue, and do
  not rerun without a separate approval
- Source destination:
  `assets/generated/source-candidates/music/world-tour-v1/`
- Runtime destination: `assets/music/`
- Source candidates are excluded from the packaged game.

## Why this is 28 tracks

World Tour has nine fixed worlds: six core worlds and three paired secret
worlds. Every world receives a distinct three-cue pack: one long route groove,
one pressure or first-boss cue, and one final-boss cue. A single neutral World
Tour hub theme bridges world selection and loadout without replacing any world
pack. Existing global cues remain authoritative for the title, Prologue,
character intros, Arsenal, Admin, stage clear, results, and ending.

Funk, Soul, and Disco are currently playable, so their packs route into combat.
House, Electro, Techno, Cosmic Boogie, Soulful Garage, and Future Funk remain
planned. Their route themes may preview their identity from the selector, while
their pressure and final-boss cues remain mapped future runtime assets and must
not be described as playable-stage music until those stages exist.

## Screen, state, and menu map

| Surface | Music decision |
|---|---|
| Title and campaign entry | Keep `title` |
| Prologue cutscenes | Keep authored Prologue cues |
| Character selection and intros | Keep authored character cues |
| World Tour world selector | New `world_tour_hub` |
| World loadout | Continue `world_tour_hub`; do not restart on entry |
| Perk Database | Reuse `arsenal` |
| Arsenal | Keep `arsenal` |
| Admin | Keep `admin` |
| Options and Controls | Continue the audible origin cue |
| Campaign reset confirmation | Continue `title` |
| Pause during a run | Continue and duck the active route or boss cue |
| Level-up and chest reward | Continue and duck the active route or boss cue |
| Evolution reveal | Keep the existing short `evolution` cue, then resume |
| Stage complete | Keep the existing stage-clear cue and sting |
| Victory and defeat results | Keep the authored results cues |
| Ending cutscene | Keep `ending_teaser` |

## Playable stage map

| World | Stage | Regular music | Boss music |
|---|---|---|---|
| Funk | The Pocket District | `world_funk_route` | `world_funk_boogie_tank` |
| Funk | The Golden Afterparty | `world_funk_route` | `world_funk_mothership` |
| Soul | The Velvet Nave | `world_soul_route` | `world_soul_organ_colossus` |
| Soul | The Sanctuary Chorus | `world_soul_route` | `world_soul_velvet_titan` |
| Disco | Mirrorball Concourse | `world_disco_route` | `world_disco_laser_conductor` |
| Disco | The Prism Platform | `world_disco_route` | `world_disco_prism_monarch` |

## Complete world-pack map

| World | Route cue | Pressure / first-boss cue | Final-boss cue |
|---|---|---|---|
| Funk | `world_funk_route` | `world_funk_boogie_tank` | `world_funk_mothership` |
| Soul | `world_soul_route` | `world_soul_organ_colossus` | `world_soul_velvet_titan` |
| Disco | `world_disco_route` | `world_disco_laser_conductor` | `world_disco_prism_monarch` |
| House | `world_house_route` | `world_house_pressure` | `world_house_kickdrum_constructor` |
| Electro | `world_electro_route` | `world_electro_pressure` | `world_electro_voltage_vandal` |
| Techno | `world_techno_route` | `world_techno_pressure` | `world_techno_loop_architect` |
| Cosmic Boogie | `world_cosmic_boogie_route` | `world_cosmic_boogie_pressure` | `world_cosmic_boogie_celestial_selector` |
| Soulful Garage | `world_soulful_garage_route` | `world_soulful_garage_pressure` | `world_soulful_garage_night_shift_conductor` |
| Future Funk | `world_future_funk_route` | `world_future_funk_pressure` | `world_future_funk_recompiler` |

## Exact generation batch

### 31 — World Tour Hub: Passport to the Pocket

- Stable ID: `world_tour_hub`
- Runtime file: `31_world_tour_hub.ogg`
- Source filename: `31-world-tour-hub-passport-to-the-pocket.mp3`
- Target: 110 BPM, 128 beats

```text
Compose a long instrumental World Tour menu theme for Groove Bound, used while choosing a route and preparing a loadout. 110 BPM, 4/4, E-flat major with colourful C-minor and F-minor turns. Polished expressive 32-bit MIDI cosmic funk and disco-soul: tight drum machine, rounded bass, clavinet, Rhodes, muted guitar, bright brass, vibraphone UI accents, keytar sparkles, and subtle sci-fi arpeggios. Carry the same urban-supernatural arcade identity as the existing soundtrack while previewing Funk, Soul, and Disco in one coherent groove. Confident, curious, spacious, and designed for long menu browsing with gentle development rather than dramatic section changes. Fully instrumental; no vocals, chants, choir, speech, crowd sounds, or vocal samples. No fade-out or final crash; finish on a clean musical pickup suitable for looping.
```

### 32 — Funk Route: Hold the Pocket

- Stable ID: `world_funk_route`
- Runtime file: `32_world_funk_route.ogg`
- Source filename: `32-world-funk-route-hold-the-pocket.mp3`
- Target: 112 BPM, 128 beats

```text
Create a long instrumental gameplay groove for Groove Bound's Funk world, covering The Pocket District and The Golden Afterparty. 112 BPM, 4/4, E-flat Dorian. Polished expressive 32-bit MIDI P-Funk, breakbeat, and cosmic arcade music: deep syncopated bass, dry pocket drums, clavinet, wah-style synth guitar, Rhodes, talkbox-like lead played only as a synth instrument, brass jabs, hand percussion, and playful spaceship arpeggios. The rhythm must feel powerful and elastic while leaving clear gaps for combat effects. Develop gradually for extended play without sudden breakdowns, vocals, or genre changes. Colourful urban-supernatural science fantasy, never parody. Fully instrumental; no singing, speech, chants, choir, crowd, or vocal chops. End with a clean rhythmic pickup for a seamless game loop.
```

### 33 — Funk Boss: Boogie Tank Lockdown

- Stable ID: `world_funk_boogie_tank`
- Runtime file: `33_world_funk_boogie_tank.ogg`
- Source filename: `33-world-funk-boss-boogie-tank-lockdown.mp3`
- Target: 118 BPM, 32 beats

The first candidate was only 34.68 seconds long and the alternate was 29.24
seconds. Neither contained a safe 64-beat window. The first candidate remains
the promoted take as a validated 32-beat boss loop; both source candidates are
preserved and no additional generation was used.

```text
Score the Boogie Tank boss in Groove Bound's Pocket District. Instrumental 118 BPM funk-battle loop in E-flat minor with Dorian flashes. Use polished 32-bit MIDI cosmic funk and arcade boss production: huge syncopated bass, stomping pocket drums, low clavinet, metallic percussion, brass warning hits, short keytar answers, and rotating spaceship synths. Make the boss feel heavy, funny, dangerous, and locked exactly on the one. Preserve readable attack gaps and a strong two-part call-and-response between the tank and the hero. Keep the same instrument palette as the Funk route but denser and more theatrical. No vocals, talkbox voice, speech, chants, choir, shouts, or crowd sounds. No final crash; return cleanly to the opening downbeat.
```

### 34 — Funk Finale: Board the Mothership

- Stable ID: `world_funk_mothership`
- Runtime file: `34_world_funk_mothership.ogg`
- Source filename: `34-world-funk-finale-board-the-mothership.mp3`
- Target: 124 BPM, 64 beats

```text
Compose the instrumental final-boss theme for the Mothership of Funk in Groove Bound's Golden Afterparty. 124 BPM, 4/4, E-flat minor rising into G-flat major flashes. Polished 32-bit MIDI cosmic P-Funk, breakbeat, and heroic arcade finale: driving bass, layered pocket drums, clavinet, wah synth guitar, wide brass, keytar lead, FM stars, hand percussion, and a giant descending mothership motif answered by an upward hero phrase. Exhilarating, stylish, colourful, and alien without becoming dark sci-fi. Build intensity while preserving short attack-telegraph gaps and clean combat headroom. Instrumental only; no vocals, talkbox words, choir, chants, speech, crowd, or vocal chops. End on a precise pickup into the first bar, not a finale chord.
```

### 35 — Soul Route: Velvet Resonance

- Stable ID: `world_soul_route`
- Runtime file: `35_world_soul_route.ogg`
- Source filename: `35-world-soul-route-velvet-resonance.mp3`
- Target: 92 BPM, 128 beats

```text
Create a long instrumental gameplay theme for Groove Bound's Soul world, covering The Velvet Nave and The Sanctuary Chorus. 92 BPM, 4/4, F minor with warm A-flat-major lifts. Polished expressive 32-bit MIDI neo-soul, gospel-funk harmony without choir, trip-hop, and cosmic arcade music: warm Rhodes, round bass, laid-back drums, muted guitar, Hammond-style synth organ, vibraphone, restrained brass, glassy arpeggios, and a patient heroic melody. The groove should feel restorative, deep, and resilient while remaining active enough for combat. Develop smoothly for extended play with no abrupt drops or style changes and leave room for SFX. Fully instrumental; no vocals, choir, gospel singing, humming, speech, chants, or vocal pads. Finish on a clean suspended pickup suitable for looping.
```

### 36 — Soul Boss: Organ Colossus

- Stable ID: `world_soul_organ_colossus`
- Runtime file: `36_world_soul_organ_colossus.ogg`
- Source filename: `36-world-soul-boss-organ-colossus.mp3`
- Target: 100 BPM, 64 beats

```text
Score the Organ Colossus boss in Groove Bound's Velvet Nave. Instrumental 100 BPM soul-funk boss loop in F minor. Use polished 32-bit MIDI Hammond-style synth organ, deep bass, heavy pocket drums, toms, muted guitar, low brass, vibraphone sparks, and cosmic sequencer pulses. Alternate monumental sustained organ chords with precise rhythmic gaps that make the boss attacks readable, while a warm hero phrase keeps pushing upward. Sacred-scale atmosphere without religious vocals, dark horror, or melodrama; this is colourful urban-supernatural science fantasy. Match the Soul route palette but make it heavier and more imposing. No choir, singing, humming, speech, chants, vocal pads, or human shouts. No final cadence; reconnect cleanly to bar one.
```

### 37 — Soul Finale: Velvet Titan Rising

- Stable ID: `world_soul_velvet_titan`
- Runtime file: `37_world_soul_velvet_titan.ogg`
- Source filename: `37-world-soul-finale-velvet-titan-rising.mp3`
- Target: 108 BPM, 64 beats

```text
Compose the instrumental final-boss theme for the Velvet Titan in Groove Bound's Sanctuary Chorus. 108 BPM, 4/4, F minor resolving through radiant A-flat major. Blend polished 32-bit MIDI neo-soul, cinematic funk, breakbeat, and arcade finale scoring: powerful drums, melodic bass, Rhodes, organ, muted guitar, brass, synthetic strings, vibraphone, and bright cosmic arpeggios. The Titan should feel enormous and soulful; the hero response should feel compassionate, determined, and rhythmically confident. Build a grand climax without constant percussion fills, muddy sub-bass, or lost attack gaps. Keep the existing soundtrack's colourful MIDI identity. Fully instrumental; no choir, singing, speech, chants, humming, vocal pads, or crowd. End with an unresolved rhythmic pickup that loops naturally.
```

### 38 — Disco Route: Mirrorball Metro

- Stable ID: `world_disco_route`
- Runtime file: `38_world_disco_route.ogg`
- Source filename: `38-world-disco-route-mirrorball-metro.mp3`
- Target: 122 BPM, 128 beats

```text
Create a long instrumental gameplay theme for Groove Bound's Disco world, covering Mirrorball Concourse and The Prism Platform. 122 BPM, 4/4, A minor with bright C-major and Dorian colour. Polished expressive 32-bit MIDI cosmic disco and arcade electro: four-on-the-floor kick, elastic octave bass, crisp hand percussion, string-synth lifts, clavinet, bright guitar chops, piano stabs, keytar, laser-like arpeggios, and glittering FM bells. Sleek, joyful, fast-moving, and slightly supernatural, with smooth development for extended combat and clear spaces for attacks and pickups. Avoid modern pop vocals and avoid cheesy retro parody; keep the same game-wide urban cosmic aesthetic. Fully instrumental; no singing, chants, choir, speech, crowd, disco calls, or vocal chops. Finish with a clean looping pickup, no fade-out.
```

### 39 — Disco Boss: Laser Conductor

- Stable ID: `world_disco_laser_conductor`
- Runtime file: `39_world_disco_laser_conductor.ogg`
- Source filename: `39-world-disco-boss-laser-conductor.mp3`
- Target: 128 BPM, 64 beats

```text
Score the Laser Conductor boss in Groove Bound's Mirrorball Concourse. Instrumental 128 BPM cosmic-disco boss loop in A minor. Use polished 32-bit MIDI four-on-the-floor drums, urgent octave bass, disco strings, sharp brass, piano stabs, metallic hand percussion, laser-like sequencer lines, and a precise keytar melody. The boss conducts sweeping beams, so create clear wind-up gaps followed by bright rhythmic bursts and crossing stereo patterns without overwhelming combat effects. Match the Disco route palette but make it focused, dangerous, and theatrical rather than grim. No vocals, disco calls, speech, chants, choir, crowd, or vocal samples. No final hit; make the final beat launch directly into the opening.
```

### 40 — Disco Finale: Prism Monarch

- Stable ID: `world_disco_prism_monarch`
- Runtime file: `40_world_disco_prism_monarch.ogg`
- Source filename: `40-world-disco-finale-prism-monarch.mp3`
- Target: 132 BPM, 64 beats

```text
Compose the instrumental final-boss theme for the Prism Monarch in Groove Bound's Prism Platform. 132 BPM, 4/4, A minor bursting into C major. Blend polished 32-bit MIDI cosmic disco, electro-funk, breakbeat, and heroic arcade finale music: driving octave bass, layered dance drums, string-synth runs, brass fanfares, piano and guitar stabs, keytar lead, FM crystal bells, and refracted arpeggios that split and reunite. Regal, dazzling, dangerous, and exuberant, with brief telegraph gaps and enough headroom for heavy combat. Echo the Disco route identity at larger scale without becoming generic EDM. Fully instrumental; no singing, speech, choir, chants, crowd, disco calls, or vocal chops. End on a precise pickup for a seamless loop rather than a closing chord.
```

### 41 — House Route: Warehouse 909

- Stable ID: `world_house_route`
- Runtime file: `41_world_house_route.ogg`
- Source filename: `41-world-house-route-warehouse-909.mp3`
- Target: 124 BPM, 128 beats

```text
Create a long instrumental gameplay identity for Groove Bound's House world, Warehouse 909. 124 BPM, 4/4, C minor with E-flat-major warmth. Polished expressive 32-bit MIDI Chicago house, deep house, and cosmic arcade funk: firm four-on-the-floor kick, rubbery bass, piano stabs, organ chords, crisp hats, rim percussion, muted-guitar sparks, bright brass, and a playful sci-fi sequencer. Hypnotic but alive, built for extended combat with gradual development, clean low end, and clear SFX space. It must belong to the same colourful urban-supernatural soundtrack while being unmistakably House, never generic festival EDM. Fully instrumental; no vocals, diva samples, spoken phrases, chants, choir, crowd, or vocal chops. No fade-out; end on a clean pickup for looping.
```

### 42 — House Pressure: Floor Cycle Overdrive

- Stable ID: `world_house_pressure`
- Runtime file: `42_world_house_pressure.ogg`
- Source filename: `42-world-house-pressure-floor-cycle-overdrive.mp3`
- Target: 128 BPM, 64 beats

```text
Compose an instrumental pressure and first-boss cue for Groove Bound's Warehouse 909. 128 BPM, 4/4, C minor. Keep the House pack palette but intensify it: heavier kick, rolling bass, urgent piano stabs, organ pulses, metallic claps, tom fills, gated brass, and cycling arpeggios that suggest a floor mechanism locking into place. Create short wind-up gaps before strong rhythmic drops so enemy attacks stay readable. Tough, mechanical, danceable, and colourful rather than dark warehouse techno. Polished 32-bit MIDI arcade production, clean combat headroom, no giant festival build. No vocals, diva calls, speech, chants, choir, crowd, or vocal samples. End on a precise beat that reconnects to the opening.
```

### 43 — House Finale: Kickdrum Constructor

- Stable ID: `world_house_kickdrum_constructor`
- Runtime file: `43_world_house_kickdrum_constructor.ogg`
- Source filename: `43-world-house-finale-kickdrum-constructor.mp3`
- Target: 130 BPM, 64 beats

```text
Score the Kickdrum Constructor, final boss of Groove Bound's House world. Instrumental 130 BPM house-funk arcade finale in C minor rising toward E-flat major. Use monumental but controlled kick patterns, elastic bass, piano and organ stabs, syncopated claps, mechanical percussion, wide brass, keytar answers, and construction-like sequencer parts assembling into one groove. The boss motif should sound built block by block; the hero response should break the grid with funky syncopation. Preserve attack-telegraph gaps and avoid nonstop impacts or muddy sub-bass. Polished expressive 32-bit MIDI, playful science fantasy, not industrial horror. No vocals, speech, diva samples, chants, choir, crowd, or vocal chops. Loop cleanly without a final crash.
```

### 44 — Electro Route: Neon Circuit

- Stable ID: `world_electro_route`
- Runtime file: `44_world_electro_route.ogg`
- Source filename: `44-world-electro-route-neon-circuit.mp3`
- Target: 118 BPM, 128 beats

```text
Create a long instrumental gameplay theme for Groove Bound's Electro world, Neon Circuit. 118 BPM, 4/4, F-sharp minor with bright A-major flashes. Polished expressive 32-bit MIDI electro-funk, breakdance electro, and cosmic arcade music: punchy drum machine, syncopated synth bass, handclaps, FM bells, vocoder-like lead played only as a pure synth, keytar, metallic percussion, short guitar harmonics, and animated circuit arpeggios. Robotic, agile, playful, and streetwise, with evolving call-and-response for extended combat and open space for SFX. Keep it distinct from Disco's four-on-the-floor sweep and Techno's repetition. Fully instrumental; no vocals, robot speech, chants, choir, crowd, or vocal samples. No fade-out; finish with a clean loop pickup.
```

### 45 — Electro Pressure: Node Chain Surge

- Stable ID: `world_electro_pressure`
- Runtime file: `45_world_electro_pressure.ogg`
- Source filename: `45-world-electro-pressure-node-chain-surge.mp3`
- Target: 126 BPM, 64 beats

```text
Compose an instrumental pressure and first-boss cue for Groove Bound's Neon Circuit. 126 BPM, 4/4, F-sharp minor. Intensify the Electro pack with harder drum-machine breaks, popping synth bass, sharp claps, FM alarms, keytar runs, metallic toms, and chained arpeggios that jump left to right like connected attack nodes. Use clear charge-up silences followed by precise bursts, keeping combat readable and the low end controlled. Futuristic street battle, colourful and technical, never grim cyberpunk or generic EDM. Polished 32-bit MIDI arcade identity consistent with Groove Bound. No vocals, robot announcements, speech, chants, choir, crowd, or vocal chops. End on a clean rhythmic reset into bar one.
```

### 46 — Electro Finale: Voltage Vandal

- Stable ID: `world_electro_voltage_vandal`
- Runtime file: `46_world_electro_voltage_vandal.ogg`
- Source filename: `46-world-electro-finale-voltage-vandal.mp3`
- Target: 132 BPM, 64 beats

```text
Score Voltage Vandal, final boss of Groove Bound's Electro world. Instrumental 132 BPM electro-funk and breakbeat arcade finale in F-sharp minor resolving through A major. Use driving syncopated bass, crisp electronic drums, claps, distorted but musical synth leads, FM lightning bells, metallic percussion, brass strikes, keytar, and rapidly branching circuit arpeggios. Give the Vandal a jagged descending voltage motif and the hero an upward rhythmic answer. High energy and flashy but with short telegraph gaps, clean transients, and no wall-of-sound mix. Polished expressive 32-bit MIDI science fantasy. No vocals, robot speech, shouts, chants, choir, crowd, or vocal samples. Loop precisely; no final explosion.
```

### 47 — Techno Route: The Iron Loop

- Stable ID: `world_techno_route`
- Runtime file: `47_world_techno_route.ogg`
- Source filename: `47-world-techno-route-the-iron-loop.mp3`
- Target: 132 BPM, 128 beats

```text
Create a long instrumental gameplay identity for Groove Bound's Techno world, The Iron Loop. 132 BPM, 4/4, D minor with restrained F-major light. Polished expressive 32-bit MIDI Detroit techno, minimal funk, and cosmic arcade scoring: disciplined kick, pulsing bass sequence, dry hats, syncopated rim percussion, chord stabs, FM metal tones, subtle keytar fragments, and evolving loop-memory patterns. Hypnotic, precise, futuristic, and powerful, but still colourful and funky rather than bleak or industrial. Develop through small mutations over extended combat without abrupt breakdowns, huge risers, or constant density. Leave clean attack and SFX space. Fully instrumental; no vocals, spoken machine voice, chants, choir, crowd, or vocal samples. End on a seamless loop pickup.
```

### 48 — Techno Pressure: Memory Loop Breach

- Stable ID: `world_techno_pressure`
- Runtime file: `48_world_techno_pressure.ogg`
- Source filename: `48-world-techno-pressure-memory-loop-breach.mp3`
- Target: 138 BPM, 64 beats

```text
Compose an instrumental pressure and first-boss cue for Groove Bound's Iron Loop. 138 BPM, 4/4, D minor. Intensify the Techno pack with a firmer kick, accelerating sequencer bass, clipped chord stabs, metallic toms, FM warning notes, and a repeating motif that mutates one note at a time as if the arena remembers earlier attacks. Maintain deliberate gaps for telegraphs and avoid nonstop fills, harsh noise, or oversized festival drops. Precise, cerebral, physical, and playful science fiction in polished 32-bit MIDI arcade production. It must sound distinct from House's piano groove and Electro's breakdance syncopation. No vocals, machine speech, chants, choir, crowd, or vocal chops. Loop cleanly with no terminal hit.
```

### 49 — Techno Finale: Loop Architect

- Stable ID: `world_techno_loop_architect`
- Runtime file: `49_world_techno_loop_architect.ogg`
- Source filename: `49-world-techno-finale-loop-architect.mp3`
- Target: 144 BPM, 64 beats

```text
Score the Loop Architect, final boss of Groove Bound's Techno world. Instrumental 144 BPM Detroit-techno and progressive arcade finale in D minor rising into F major. Use commanding kick and tom geometry, sequenced bass, metallic hats, staccato chord architecture, FM bells, wide synth brass, restrained keytar, and interlocking arpeggios that assemble a musical machine. Let the boss motif repeat with structural changes while the hero motif disrupts it through syncopation. Monumental and intelligent, not bleak; keep short attack gaps, controlled sub-bass, and clear SFX headroom. Polished expressive 32-bit MIDI. No vocals, machine announcements, chants, choir, crowd, or vocal samples. End on a mathematically clean pickup to bar one.
```

### 50 — Cosmic Boogie Route: Orbital Dance Deck

- Stable ID: `world_cosmic_boogie_route`
- Runtime file: `50_world_cosmic_boogie_route.ogg`
- Source filename: `50-world-cosmic-boogie-route-orbital-dance-deck.mp3`
- Target: 116 BPM, 128 beats

```text
Create a long instrumental gameplay theme for Groove Bound's secret Cosmic Boogie world, Orbital Dance Deck, born from Funk and Disco. 116 BPM, 4/4, E-flat Dorian with luminous C-major detours. Polished expressive 32-bit MIDI boogie, P-Funk, cosmic disco, and arcade science fantasy: elastic bass, pocket drums plus light four-on-the-floor lift, clavinet, guitar chops, disco strings, brass, keytar, FM stars, and orbiting arpeggios. It must clearly fuse Funk's syncopated weight with Disco's glittering motion while becoming its own playful zero-gravity groove. Develop smoothly for long combat and leave SFX space. Fully instrumental; no vocals, talkbox words, disco calls, chants, choir, crowd, or vocal chops. Finish on a clean orbital pickup for looping.
```

### 51 — Cosmic Boogie Pressure: Zero-G Pocket

- Stable ID: `world_cosmic_boogie_pressure`
- Runtime file: `51_world_cosmic_boogie_pressure.ogg`
- Source filename: `51-world-cosmic-boogie-pressure-zero-g-pocket.mp3`
- Target: 124 BPM, 64 beats

```text
Compose an instrumental pressure and first-boss cue for Groove Bound's Orbital Dance Deck. 124 BPM, 4/4, E-flat minor with bright Dorian colour. Combine heavy funk bass and clavinet with disco strings, firm dance drums, brass alarms, keytar streaks, FM star bells, and spiralling arpeggios that imply shifting gravity. Use brief weightless dropouts before strong downbeats so attacks remain readable. Energetic, alien, joyful, and dangerous without becoming generic space disco. Keep the polished 32-bit MIDI urban-supernatural arcade identity and controlled combat mix. No vocals, talkbox words, disco calls, speech, chants, choir, crowd, or vocal samples. End with a clean re-entry to the opening groove.
```

### 52 — Cosmic Boogie Finale: Celestial Selector

- Stable ID: `world_cosmic_boogie_celestial_selector`
- Runtime file: `52_world_cosmic_boogie_celestial_selector.ogg`
- Source filename: `52-world-cosmic-boogie-finale-celestial-selector.mp3`
- Target: 130 BPM, 64 beats

```text
Score the Celestial Selector, final boss of Groove Bound's Cosmic Boogie world. Instrumental 130 BPM cosmic-boogie arcade finale in E-flat minor opening into C major. Use huge elastic bass, layered pocket and dance drums, clavinet, disco strings, brass, wah synth guitar, keytar, FM constellations, and rotating arpeggios that select and rearrange motifs from Funk and Disco. Regal DJ-like control without any DJ voice: the boss chooses the groove, the hero steals it back through syncopation. Dazzling, funny, dangerous, with clear telegraph gaps and clean low end. Polished expressive 32-bit MIDI. No vocals, speech, talkbox words, disco calls, chants, choir, crowd, or vocal chops. Seamless loop, no final crash.
```

### 53 — Soulful Garage Route: Midnight Garage

- Stable ID: `world_soulful_garage_route`
- Runtime file: `53_world_soulful_garage_route.ogg`
- Source filename: `53-world-soulful-garage-route-midnight-garage.mp3`
- Target: 132 BPM, 128 beats

```text
Create a long instrumental gameplay theme for Groove Bound's secret Soulful Garage world, Midnight Garage, born from Soul and House. 132 BPM, 4/4 with a shuffled UK-garage feel, F minor with warm A-flat-major lifts. Polished expressive 32-bit MIDI soulful garage and cosmic arcade funk: skipping drums, round sub-bass, Rhodes chords, organ, clipped guitar, soft brass, vibraphone, bright piano stabs, and nocturnal sci-fi arpeggios. Blend Soul's warmth and recovery with House's floor momentum into a distinct late-night urban-supernatural groove. Smooth development for extended combat, clean low end, and generous SFX space. Fully instrumental; no vocals, diva samples, choir, humming, speech, chants, crowd, or vocal chops. End on a clean shuffled pickup for looping.
```

### 54 — Soulful Garage Pressure: Resonance Gate

- Stable ID: `world_soulful_garage_pressure`
- Runtime file: `54_world_soulful_garage_pressure.ogg`
- Source filename: `54-world-soulful-garage-pressure-resonance-gate.mp3`
- Target: 136 BPM, 64 beats

```text
Compose an instrumental pressure and first-boss cue for Groove Bound's Midnight Garage. 136 BPM, shuffled 4/4, F minor. Intensify soulful garage with tighter broken drums, pulsing sub-bass, urgent Rhodes, organ swells, piano stabs, metallic rim percussion, muted brass, and gated arpeggios that open and close like charged resonance barriers. Create short breath-like spaces using instruments only before attack bursts; never use human sounds. Warm but urgent, nocturnal but colourful, with polished 32-bit MIDI arcade clarity and controlled SFX headroom. No vocals, diva samples, choir, humming, speech, chants, crowd, or vocal chops. Finish with a clean skip back into the first bar.
```

### 55 — Soulful Garage Finale: Night Shift Conductor

- Stable ID: `world_soulful_garage_night_shift_conductor`
- Runtime file: `55_world_soulful_garage_night_shift_conductor.ogg`
- Source filename: `55-world-soulful-garage-finale-night-shift-conductor.mp3`
- Target: 140 BPM, 64 beats

```text
Score the Night Shift Conductor, final boss of Groove Bound's Soulful Garage world. Instrumental 140 BPM shuffled garage and neo-soul arcade finale in F minor rising through A-flat major. Use powerful broken drums, melodic sub-bass, Rhodes, organ, piano stabs, brass, synthetic strings, keytar, metallic station percussion, and luminous midnight arpeggios. The Conductor controls gates and rhythmic stops; answer each commanding motif with a resilient warm hero phrase. Grand and urgent without losing swing, attack gaps, or clean combat headroom. Polished expressive 32-bit MIDI urban science fantasy. No vocals, train announcements, diva samples, choir, humming, speech, chants, crowd, or vocal chops. Loop cleanly, no closing cadence.
```

### 56 — Future Funk Route: Tomorrow Mall

- Stable ID: `world_future_funk_route`
- Runtime file: `56_world_future_funk_route.ogg`
- Source filename: `56-world-future-funk-route-tomorrow-mall.mp3`
- Target: 116 BPM, 128 beats

```text
Create a long instrumental gameplay identity for Groove Bound's secret Future Funk world, Tomorrow Mall, born from Electro and Techno. 116 BPM, 4/4, B minor with glossy D-major flashes. Polished expressive 32-bit MIDI future funk, electro, sample-inspired arcade pop without copyrighted samples: punchy drums, chopped-style instrumental chord stabs, rubbery bass, FM bells, bright synth brass, keytar, clean guitar fragments, glassy pads, and looping mall-sign arpeggios. Nostalgic for an imaginary future, playful and surreal, but still combat-ready with gradual development and clear SFX space. Distinct from Disco: more digital, chopped, and uncanny. Fully instrumental; no vocals, speech, ads, chants, choir, crowd, or vocal chops. No fade-out; end on a seamless pickup.
```

### 57 — Future Funk Pressure: Sample Memory Corrupt

- Stable ID: `world_future_funk_pressure`
- Runtime file: `57_world_future_funk_pressure.ogg`
- Source filename: `57-world-future-funk-pressure-sample-memory-corrupt.mp3`
- Target: 124 BPM, 64 beats

```text
Compose an instrumental pressure and first-boss cue for Groove Bound's Tomorrow Mall. 124 BPM, 4/4, B minor. Intensify the Future Funk pack with harder electronic drums, chopped-style instrumental stabs, pulsing bass, FM warning bells, metallic claps, warped keytar, digital brass, and loop fragments that reassemble into new patterns without using any real samples. Use brief corrupted dropouts and clean attack gaps, not noisy glitches or giant EDM risers. Bright, uncanny, technical, and playful in polished 32-bit MIDI arcade production with controlled low end. No vocals, spoken ads, chants, choir, crowd, or vocal samples. End on a precise digital pickup into bar one.
```

### 58 — Future Funk Finale: The Recompiler

- Stable ID: `world_future_funk_recompiler`
- Runtime file: `58_world_future_funk_recompiler.ogg`
- Source filename: `58-world-future-funk-finale-the-recompiler.mp3`
- Target: 132 BPM, 64 beats

```text
Score The Recompiler, final boss of Groove Bound's Future Funk world. Instrumental 132 BPM future-funk, electro, and techno arcade finale in B minor resolving through D major. Use commanding digital drums, rubber bass, chopped-style original MIDI chords, FM crystal bells, bright brass, metallic percussion, keytar, glassy strings, and arpeggios that deconstruct then rebuild the world themes without copying real recordings. The boss rewrites motifs; the hero restores their groove through a bold rhythmic answer. Dazzling, uncanny, triumphant, with readable attack gaps and clean combat headroom. Polished expressive 32-bit MIDI, no generic festival drop. No vocals, speech, advertisements, chants, choir, crowd, or vocal chops. Seamless loop; no final crash.
```

## Runtime integration contract

1. Preserve each selected Suno MP3 as a source candidate with song ID, duration,
   prompt, model, and hash in the manifest.
2. Promote route and hub cues as 128-beat 48 kHz stereo OGG Vorbis loops;
   promote boss cues as 64-beat loops, except the validated 32-beat Boogie
   Tank source-length exception recorded above.
3. Normalize near -18 LUFS, keep true peak at or below -0.8 dBFS, and validate
   codec, channels, duration, audible edges, and seam jump.
4. Route World Tour by `world_id`, `stage_index`, and `boss_id`.
5. Keep World Tour and loadout continuous. Keep the active gameplay cue under
   Pause, Options, Controls, Level Up, and Chest Reward; duck it for legibility.
6. Add catalog, router, context, content-validation, media, and package tests.
7. Prove every promoted OGG is present in the packaged `.love` and every Suno
   source candidate is absent.

## Delivery gates after integration

- Full tests and lint
- Independent audio audit
- Package archive integrity and manifest
- Packaged graphical boot
- Manual listening for vocals, clipping, loop seams, repetition, SFX masking,
  pause/resume, volume, and world-to-world transitions
- Focused World Tour playthrough and screenshots
- Scoped commit and feature-branch push
- Windows x64 artifact build and published-release verification
- Landing-page download-link/version verification
- FTP remains a separate human-approved upload step
