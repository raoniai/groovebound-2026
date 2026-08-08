# Groove Bound — 32-Beat MIDI Soundtrack Prompt Library

This library maps the current two-stage campaign and its interface states to a
cohesive instrumental soundtrack. Every cue has two alternative genre routes.
They are designed as auditions: choose one route per cue, then refine the
selected tracks into a consistent final score.

## Core soundtrack rules

- **Format:** exactly 32 beats, meaning 8 bars of 4/4, with a seamless loop.
- **Aesthetic:** polished 32-bit-era game soundtrack built from expressive MIDI-style instruments, not raw 8-bit chip tones.
- **Vocals:** fully instrumental. No singing, spoken words, rap, chants, choir, vocal chops, vocoder, or human voice textures.
- **Game clarity:** a memorable motif, strong pulse, controlled low end, and enough midrange space for combat sound effects.
- **Looping:** beat 32 must lead naturally back into beat 1. Avoid long fades, final crash endings, or reverb tails that expose the loop point.
- **Musical identity:** playful arcade energy, urban supernatural music culture, cosmic machinery, colourful heroism, and rising danger without grim realism.
- **Shared palette:** MIDI drum machines, punchy sampled drums, FM and wavetable synths, electric bass, keytar, brass, mallets, guitar, turntable-like synth gestures, orchestral synth layers, and restrained chiptune accents.
- **Deliverables:** request a full mix plus drums, bass, harmony, melody, and tension stems when the generation tool supports stems.

## Cohesion map

| World / state | Main musical colours |
|---|---|
| Backbeat city and menus | E-flat major / C minor, street funk, breakbeat, neo-soul chords, bright arcade synths |
| Joe | Low brass, warm electric bass, swung drums, sturdy square-wave lead |
| Lyra Vex | Keytar, distorted MIDI guitar, fast arpeggios, electro-rock drums |
| The Break and hostile machines | Tritones, reversed MIDI notes, bit-crushed percussion, unstable pitch bends |
| Orbit Line | F-sharp minor / A major, cosmic disco, synthwave, liquid drum and bass, glassy FM tones |
| Grand Conductor threat | C minor returning in altered form, orchestral synth brass, mechanical ostinato, distant cosmic pulses |

---

## 01. Title screen — “Groove Bound”

### Prompt A — Future-funk arcade identity

```text
Create an instrumental title-screen theme for Groove Bound, a colourful urban-supernatural survivor roguelike where music powers a city and cosmic instrument-machines invade it. Exactly 32 beats total: 8 bars of 4/4 at 112 BPM, seamless loop, E-flat major with brief C-minor colour. Polished 32-bit-era MIDI game soundtrack, future-funk and arcade breakbeat style. Open with a four-note Groove Bound hero motif on bright FM electric piano, answer it with keytar, then add punchy MIDI drums, elastic synth bass, muted brass stabs, and tiny chiptune sparkles. Confident, playful, immediately memorable, with a hint of danger in bar 7 before bar 8 turns naturally back to bar 1. Full instrumental only: no vocals, speech, chants, choir, vocal chops, or vocoder. Leave clean space for menu sound effects; no fade-out and no final crash.
```

### Prompt B — Neon rock and synthwave identity

```text
Compose a bold instrumental title loop for Groove Bound. Exactly 32 beats, 8 bars in 4/4 at 118 BPM, seamless looping, C minor resolving toward E-flat major. Use expressive 32-bit MIDI-style production: gated synthwave drums, driving picked synth bass, crunchy but controlled MIDI electric guitar, neon keytar lead, short orchestral-synth hits, and subtle record-scratch gestures made with synth pitch bends. Blend electro-rock, synthwave, and arcade music. State a compact four-note hero theme in bars 1–2, develop it in bars 3–6, reveal a cosmic dissonance in bar 7, and make bar 8 pull directly into the opening. Heroic and inviting rather than dark. Instrumental only, absolutely no human voices or vocal-like samples. No long intro, no fade, no terminal ending.
```

## 02. Prologue — Backbeat before the Break

### Prompt A — Rooftop neo-soul

```text
Create a warm instrumental cutscene cue for Backbeat, a city where train lines, street lights, rooftops, and clubs all move through a living musical network called the Resonance. Exactly 32 beats, 8 bars of 4/4 at 92 BPM, seamless but cinematic loop, E-flat major. Polished MIDI neo-soul and lo-fi city funk: Rhodes-style electric piano, round electric bass, brushed drum-machine groove, soft brass pads, marimba street-light accents, and a simple four-note hero motif heard as part of everyday city life. Bars 1–4 feel welcoming and alive; bars 5–7 introduce a faint reversed-synth shadow; bar 8 remains unresolved enough to return to bar 1. Instrumental only with no vocals, spoken narration, choir, vocal pads, or vocal chops. Keep dialogue space in the middle frequencies.
```

### Prompt B — Night-train garage groove

```text
Generate an instrumental establishing cue for the city of Backbeat before disaster. Exactly 32 beats, 8 bars in 4/4 at 126 BPM, seamless loop, E-flat major with suspended harmony. Use polished 32-bit MIDI instruments and a gentle UK-garage rhythm: shuffled electronic drums, soft sub bass, glassy electric piano, plucked synth resembling train signals, restrained keytar melody, and distant orchestral-synth strings. It should feel like a playful neon city breathing in time, energetic but not combat music. Let one reversed note enter near the end as the first sign that the sky is about to miss a beat. Fully instrumental; no singing, talking, chants, choir, vocal samples, or vocal-like pads. No fade-out.
```

## 03. Prologue — The Break arrives

### Prompt A — Reversed glitch-electro

```text
Score the instant called the Break, when a cosmic chord plays backwards through every speaker in Backbeat and instrument-machines begin invading. Exactly 32 beats, 8 bars of 4/4 at 100 BPM, seamless loop, C minor with tritone tension. 32-bit-era MIDI glitch-electro: reverse-piano attacks, detuned FM bells, stuttering drum-machine hits, bit-crushed toms, sub pulses, metallic synth brass, and fragments of the Groove Bound four-note motif played backwards. Start with deceptive calm for 8 beats, fracture the groove across beats 9–24, then form a threatening mechanical pulse for the final 8 beats that loops cleanly into the opening. Cinematic but readable under dialogue. Fully instrumental: no vocals, speech, chants, choir, breathing, vocal chops, or vocoder. No horror scream effects and no final boom.
```

### Prompt B — Supernatural IDM rupture

```text
Compose an instrumental supernatural-cosmic rupture cue for Groove Bound’s prologue. Exactly 32 beats, 8 bars in 4/4 at 108 BPM, loopable, C minor. Blend MIDI IDM, dark electro, and synthetic chamber music: prepared-piano patch, pizzicato synth strings, unstable theremin-like lead played clearly as an instrument, broken breakbeats, low brass pulses, and clockwork percussion. The rhythm should sound as if a familiar city groove has been sampled, reversed, and reassembled by alien machinery. Preserve a playful science-fantasy tone rather than realistic horror. The last bar must create a clean pickup to bar 1. Instrumental only; exclude all voices, vocal pads, choir, chanting, spoken transmissions, and vocal samples.
```

## 04. Prologue — Emergency broadcast and hero resolve

### Prompt A — Heroic breakbeat signal

```text
Create an instrumental cutscene cue for an emergency broadcast announcing that Pulse Tower is offline, followed by Joe deciding to answer the downbeat. Exactly 32 beats, 8 bars of 4/4 at 116 BPM, seamless loop, C minor rising toward E-flat major. Use punchy 32-bit MIDI breakbeats, low brass, electric bass, urgent synth arpeggios, snare rolls, and a firm square-wave lead stating the four-note hero motif. First 16 beats: controlled emergency tension with filtered radio-like synth texture but no speech. Final 16 beats: grounded confidence and forward motion, not triumph yet. Make beat 32 a pickup into beat 1. Fully instrumental; no broadcast voice, vocals, rap, chanting, choir, vocoder, or vocal chops. Keep dialogue intelligible.
```

### Prompt B — Street-cinematic hip-hop

```text
Generate a dialogue-friendly instrumental resolve theme for Groove Bound’s prologue as Backbeat calls its Resonants to action. Exactly 32 beats, 8 bars in 4/4 at 96 BPM, seamless loop, C minor. Blend cinematic boom-bap, synth orchestra, and arcade scoring: weighty kick and snare, warm bass guitar patch, low piano, brass swells, subtle vinyl-like rhythmic noise made without voice samples, and a rising keytar version of the hero motif. Feel determined, street-level, colourful, and ready for action. Build from uncertainty to a confident final bar that reconnects naturally to the first. No vocals of any kind, no spoken emergency message, no choir, no human shouts, and no fade-out.
```

## 05. Character selection

### Prompt A — Arcade funk showroom

```text
Compose a character-selection loop for choosing between Joe, the durable Backbeat guardian, and Lyra Vex, the fast Live Wire rocker. Exactly 32 beats, 8 bars of 4/4 at 120 BPM, seamless loop, E-flat major. Polished MIDI arcade funk: slap-style synth bass, crisp drum machine, clavinet, bright menu mallets, brass stabs, and alternating two-bar lead colours—warm low square lead for Joe, electric keytar and guitar harmonics for Lyra. Balanced, exciting, and neutral so neither hero feels like the default. Include the Groove Bound four-note motif as the common link. Fully instrumental with no voices, name callouts, choir, chants, or vocal chops. Keep transients clean for selection sound effects.
```

### Prompt B — Electro-rock versus beat

```text
Create an instrumental 32-bit MIDI character-select theme built as a friendly musical face-off between Joe and Lyra Vex. Exactly 32 beats, 8 bars of 4/4 at 128 BPM, perfect loop, C minor with bright E-flat-major lifts. Alternate sturdy hip-hop drums and brass-bass phrases for Joe with fast electro-rock guitar, keytar arpeggios, and double-time hi-hats for Lyra, then combine both palettes in the last two bars. Energetic, stylish, playful, never aggressive. No vocals, spoken names, chants, crowd noises, choir, or vocal-like synths. No ending cadence; beat 32 must lead back into beat 1.
```

## 06. Joe character intro — “The Backbeat”

### Prompt A — Heavy street funk

```text
Write Joe’s instrumental character-introduction cue for Groove Bound. Joe is a steady street guardian: durable, powerful, hard to displace, carrying a Kazoo Pistol and the Hold the Line trait. Exactly 32 beats, 8 bars of 4/4 at 98 BPM, seamless loop, C minor. Use 32-bit MIDI street funk and boom-bap: thick electric bass, grounded kick and snare, low brass punches, muted guitar, vibraphone accents, and a warm square-wave lead. Transform the four-note hero motif into a weighty, unhurried phrase. Add one playful buzzing synth ornament that hints at the Kazoo Pistol without sounding comedic. Confident and protective, with room for dialogue. Instrumental only; no rap, speech, singing, chants, choir, vocal grunts, or vocal samples.
```

### Prompt B — Brass-and-breaks guardian theme

```text
Compose an instrumental hero cue for Joe, the Backbeat, during his character intro. Exactly 32 beats, 8 bars in 4/4 at 110 BPM, seamless loop, C Dorian. Polished MIDI breakbeat with soul-jazz colours: syncopated drums, upright-style synth bass, baritone brass, electric piano chords, short kazoo-like synth lead used tastefully, and sturdy tom fills. The melody should feel dependable, strong, slightly cheeky, and built to hold the centre under pressure. State Joe’s variation of the shared four-note motif in bars 1 and 5. End with a rhythmic pickup, not a finale. No vocals, dialogue, choir, chants, scatting, or human voice textures.
```

## 07. Lyra Vex character intro — “The Live Wire”

### Prompt A — Electro-rock keytar

```text
Write Lyra Vex’s instrumental character-introduction cue for Groove Bound. Lyra is a cosmic rock explorer: fast, daring, high-tempo, carrying a Keytar Chord and treating danger like a stage entrance. Exactly 32 beats, 8 bars of 4/4 at 142 BPM, seamless loop, F minor with bright A-flat-major flashes. Polished 32-bit MIDI electro-rock: distorted but precise guitar patch, flashy keytar lead, driving synth bass, punchy live-electronic drums, handclap-style MIDI percussion, and cosmic arpeggios. Her version of the four-note hero motif should leap upward and answer itself with a fast run. Bold, playful, charismatic, never macho or grim. Fully instrumental; no vocals, shouts, crowd chants, choir, vocal chops, or spoken lines.
```

### Prompt B — Pop-punk drum and bass

```text
Create an instrumental intro loop for Lyra Vex, the Live Wire. Exactly 32 beats, 8 bars in 4/4 at 168 BPM, seamless loop, F minor. Blend melodic drum and bass, arcade pop-punk, and MIDI keytar: rapid breakbeat, bright picked bass, palm-muted synth guitar, wide keytar chords, sparkling FM bells, and a fearless lead melody. The first half should feel like she has just jumped onto a rooftop stage; the second half adds a cosmic signal answering her riff. Keep the mix agile and clean for dialogue. No singing, vocal hooks, spoken words, crowd noise, chants, choir, or vocal samples. Beat 32 must propel directly into beat 1.
```

## 08. Stage 1 gameplay — Backbeat Streets, opening waves

### Prompt A — Urban supernatural funk

```text
Generate the main opening gameplay loop for Stage 1, Backbeat Streets, as Monotones, Tempo Leeches, and Syncopation Skitters enter the neon service alleys around Pulse Tower. Exactly 32 beats, 8 bars of 4/4 at 124 BPM, seamless loop, C Dorian. Polished MIDI urban funk plus breakbeat: elastic bass, tight drums, electric piano, muted guitar, marimba notes, brass jabs, and playful synth arpeggios. Include a clear rhythmic pocket that makes movement and automatic attacks feel musical without forcing every action onto the beat. Add small off-beat glitches that suggest the invading Break. Energetic but spacious enough for combat SFX. Fully instrumental, no vocals, chants, choir, shouts, vocal chops, or speech.
```

### Prompt B — Neon garage patrol

```text
Compose a seamless instrumental combat loop for the early Backbeat Streets stage in Groove Bound. Exactly 32 beats, 8 bars of 4/4 at 132 BPM, C minor. Use polished 32-bit MIDI UK garage and arcade electro: shuffled drums, springy sub bass, bright plucks, short brass hits, FM organ, and a nimble lead derived from the Groove Bound motif. The tone is colourful urban supernatural adventure, not grim cyberpunk. Leave headroom and rhythmic gaps for projectile, XP, and enemy-death sounds. Bars 7–8 should raise mild tension then return cleanly to bar 1. No voices, vocals, rap, choir, chants, or vocal samples.
```

## 09. Stage 1 gameplay — pressure rising

### Prompt A — Breakbeat escalation

```text
Create the mid-stage escalation loop for Backbeat Streets as Feedback Phantoms, Bass Brutes, and Noise Turrets join the crowd. Exactly 32 beats, 8 bars of 4/4 at 138 BPM, seamless loop, C minor. 32-bit MIDI big beat and electro-funk: heavier break drums, distorted synth bass, syncopated brass, wah-style synth guitar, alarm-like arpeggio, and chopped instrumental stabs with no voices. Make the groove denser than the opening-stage cue while preserving the same four-note motif and tonal family. Suggest zigzags, charges, and ranged attacks through rhythmic call-and-response. Intense but playful, readable under many combat sounds. Instrumental only; no vocals, choir, shouting, chants, or vocal chops.
```

### Prompt B — Electro-swing machinery

```text
Compose an instrumental pressure loop for the middle of Backbeat Streets. Exactly 32 beats, 8 bars in 4/4 at 144 BPM, seamless loop, C harmonic minor with brief Dorian relief. Blend MIDI electro-swing, breakbeat, and supernatural arcade music: mechanical upright-bass patch, tight electronic drums, muted trumpet, detuned piano, metallic percussion, and a flickering synth lead. The rhythm should feel like hostile machines have learned the city’s dance incorrectly. Keep it stylish and kinetic, not comedic or old-fashioned. Strong loop point, no fade. No vocals, scatting, spoken samples, choir, chants, or human noises.
```

## 10. Stage 1 miniboss — Metronome Guardian

### Prompt A — Clockwork techno duel

```text
Score the Metronome Guardian miniboss in Groove Bound: a charging clockwork instrument-machine protecting Pulse Tower. Exactly 32 beats, 8 bars of 4/4 at 136 BPM, seamless loop, C minor. Polished 32-bit MIDI clockwork techno with breakbeat accents: hard metronome click used musically, pounding kick, syncopated toms, pulsing synth bass, low brass, ticking woodblocks, and an angular lead melody. Create predictable quarter-note authority, then disrupt it with syncopation as the boss charges. Quote the Groove Bound motif in a minor, mechanical form. Urgent and theatrical, never horror. Instrumental only; no countdown voice, vocals, choir, chants, grunts, or voice-like samples.
```

### Prompt B — Progressive percussion battle

```text
Compose a 32-beat instrumental miniboss loop for the Metronome Guardian. Use 8 bars of 4/4 at 152 BPM, seamless looping, C Phrygian dominant used lightly. Blend progressive electronic rock, MIDI percussion ensemble, and arcade boss music: gated toms, metallic snare, staccato bass guitar patch, organ, synth-brass hits, and a sharp square-wave lead. Alternate straight clock pulses with displaced accents to evoke the Guardian’s charge pattern. The final bar should feel like the mechanism resets into bar 1. No singing, spoken counting, shouts, choir, chants, or vocal effects.
```

## 11. Stage 1 gameplay — final-wave overload

### Prompt A — Drum-and-bass street siege

```text
Create the late-stage combat loop for Backbeat Streets when every enemy family floods the arena before the Static Baron. Exactly 32 beats, 8 bars of 4/4 at 174 BPM, seamless loop, C minor. Polished 32-bit MIDI drum and bass: crisp chopped break, deep but controlled synth bass, urgent electric piano stabs, brass alarms, rapid arpeggio, guitar harmonics, and a heroic counter-melody. It should feel like the player’s build has become powerful while the city is under maximum pressure. Keep the low end clean and avoid constant wall-of-sound density so combat effects remain audible. Instrumental only—no vocals, vocal chops, chants, choir, shouts, or speech.
```

### Prompt B — Arcade electro-rock siege

```text
Generate an instrumental end-of-stage battle loop for Backbeat Streets. Exactly 32 beats, 8 bars in 4/4 at 150 BPM, seamless loop, C minor with E-flat-major flashes. Combine MIDI electro-rock, breakbeat, and heroic arcade scoring: aggressive synth guitar rhythm, punchy electronic kit, octave bass, bright keytar, low orchestral-synth brass, and short chiptune accents. Bring Joe’s and Lyra’s musical colours together so either selected character feels supported. High-energy, colourful, empowering, not bleak. No vocals, choir, chants, crowd sounds, spoken phrases, or guitar feedback that resembles screaming.
```

## 12. Stage 1 final boss — Static Baron

### Prompt A — Glitch-hop broadcast tyrant

```text
Score the Static Baron, the immobile Stage 1 final boss broadcasting hostile notes across Backbeat Streets. Exactly 32 beats, 8 bars of 4/4 at 110 BPM, seamless loop, C minor with tritone tension. 32-bit MIDI glitch-hop and bass music: huge syncopated synth bass, clipped drum breaks, radio-static percussion synthesized without speech, ominous organ, metallic brass, and corrupted fragments of the hero motif. The boss feels aristocratic, theatrical, and technologically supernatural. Build a clear call-and-response between the Baron’s heavy broadcast phrase and the hero’s defiant lead. Full instrumental only; no announcer, vocals, choir, chants, whispers, or vocal samples. Controlled low end for attack SFX, no final ending.
```

### Prompt B — Industrial synthwave monarch

```text
Compose a seamless instrumental boss loop for the Static Baron. Exactly 32 beats, 8 bars in 4/4 at 128 BPM, C harmonic minor. Blend industrial synthwave, MIDI pipe organ, distorted drum machine, pulsing sequencer bass, orchestral-synth brass, and a cutting keytar lead. Give the Baron a descending three-note static motif and let the Groove Bound four-note hero motif answer it in the final two bars. Menacing yet flamboyant, like a cosmic broadcast monarch inside a broken amplifier. No vocals, speech, radio dialogue, choir, chanting, vocal chops, or human noises. Beat 32 must snap perfectly back to beat 1.
```

## 13. Inter-stage cutscene — The First Press

### Prompt A — Map pretending to be music

```text
Create an instrumental discovery cue for the cutscene after the Static Baron falls and Joe and Lyra find the First Press, a strange record encoding a map as music. Exactly 32 beats, 8 bars of 4/4 at 88 BPM, seamless cinematic loop, move from C minor toward F-sharp minor. Use polished MIDI trip-hop and cosmic jazz: dusty electronic drums, upright-style synth bass, Rhodes chords, vibraphone, reversed record-spin synth gesture, muted trumpet, and glassy space arpeggios. First half feels mysterious and tactile; second half reveals that the signal points to the abandoned Orbit Line. Curious and propulsive, not sinister. Fully instrumental; no dialogue, vocals, choir, whispers, spoken transmission, or vocal samples.
```

### Prompt B — Cosmic rail revelation

```text
Compose an instrumental inter-stage cutscene loop for discovering the First Press and the hidden route beneath Backbeat. Exactly 32 beats, 8 bars in 4/4 at 104 BPM, seamless loop. Begin in C minor and pivot elegantly to F-sharp minor by bar 5. Use 32-bit MIDI cinematic electronica: pulsing bass, soft breakbeat, music-box synth, keytar harmonics, synthetic strings, train-signal bell, and a spiralling arpeggio that feels like a map unfolding from a vinyl groove. Maintain dialogue space and a sense of adventurous revelation. No vocals, speech, choir, chants, whispers, or vocal-like pads; no fade-out.
```

## 14. Inter-stage recovery — riding the dead line

### Prompt A — Ambient beat recovery

```text
Generate an instrumental recovery loop as the hero carries the complete Stage 1 build into the abandoned Orbit Line. Exactly 32 beats, 8 bars of 4/4 at 90 BPM, seamless loop, F-sharp minor with A-major warmth. Polished MIDI ambient breakbeat: soft kick and rim, warm sub bass, electric piano, suspended synth strings, distant FM station bells, and a slow version of the hero motif. It should feel like catching one breath while moving deeper into danger, with no loss of momentum. Leave wide dialogue and interface space. Instrumental only—no vocals, spoken train announcements, choir, whispers, vocal pads, or vocal samples.
```

### Prompt B — Zero-gravity jazz-hop

```text
Compose a calm but forward-moving instrumental cue for the transition into the Orbit Line. Exactly 32 beats, 8 bars in 4/4 at 96 BPM, seamless loop, F-sharp Dorian. Blend MIDI jazz-hop and weightless synthwave: brushed electronic drums, fretless synth bass, electric piano ninth chords, soft keytar, glass marimba, and slowly rotating stereo arpeggios. Suggest an old rail platform broadcasting to the stars. Reflect survival, recovery, and curiosity rather than sadness. No vocals, speech, choir, station announcements, vocal chops, or humming. No final cadence.
```

## 15. Stage 2 gameplay — Orbit Line arrival

### Prompt A — Cosmic disco pursuit

```text
Create the opening gameplay loop for Stage 2, the Orbit Line: an abandoned orbital rail fused with alien amplifiers, cosmic speakers, and impossible light, populated by Vinyl Drones and Trumpet Rays. Exactly 32 beats, 8 bars of 4/4 at 126 BPM, seamless loop, F-sharp minor with A-major colour. Polished 32-bit MIDI cosmic disco: four-on-the-floor kick layered with breakbeat details, octave synth bass, glassy FM keys, disco-string synths, muted guitar, trumpet-like lead, and orbiting arpeggios. Adventurous, strange, colourful, and more spacious than Stage 1. Include a transformed version of the hero motif. Fully instrumental; no vocals, disco shouts, choir, chants, vocoder, or vocal samples.
```

### Prompt B — Orbital synthwave run

```text
Compose an instrumental arrival loop for gameplay on the Orbit Line. Exactly 32 beats, 8 bars in 4/4 at 132 BPM, seamless loop, F-sharp minor. Blend synthwave, arcade electro, and MIDI space-jazz: gated drums, pulsing bass sequence, wide keytar chords, glass bells, restrained electric guitar, synthetic brass, and a melody that rises like a rail line leaving Earth. Add rhythmic gaps for Vinyl Drone collisions and Trumpet Ray projectiles. Wonder and motion first, danger second. No vocals, spoken station messages, choir, chants, vocal pads, or vocal chops.
```

## 16. Stage 2 gameplay — alien orchestra escalation

### Prompt A — Liquid drum-and-bass constellation

```text
Generate the mid-stage Orbit Line combat loop as Drum Wheels, Theremin Jellies, Amp Hounds, and Keyboard Centipedes combine charge, pulse, orbit, and zigzag pressure. Exactly 32 beats, 8 bars of 4/4 at 172 BPM, seamless loop, F-sharp minor. Polished MIDI liquid drum and bass with cosmic fusion: rolling break, clean sub bass, electric piano, rapid keyboard arpeggios, theremin-style instrumental lead, synth guitar accents, and tuned percussion. Layers should enter like sections of an alien orchestra but remain clear enough for dense game SFX. Energetic, agile, wondrous, increasingly dangerous. Instrumental only; no vocal chops, singing, choir, chants, speech, or breath sounds.
```

### Prompt B — Psychedelic electro-fusion

```text
Create an instrumental escalation loop for the Orbit Line’s mixed alien-machine waves. Exactly 32 beats, 8 bars in 4/4 at 148 BPM, seamless loop, F-sharp Phrygian with A-major flashes. Blend MIDI psychedelic electro, jazz fusion, and arcade boss-run energy: syncopated drums, sequenced bass, keytar solo fragments, brass bursts, tom wheels, glassy theremin-like synth, and a crawling chromatic keyboard pattern. The arrangement should suggest different instrument-creatures locking into one hostile ensemble. Colourful and exhilarating rather than nightmarish. No vocals, choir, chants, shouts, vocoder, or vocal samples.
```

## 17. Stage 2 miniboss — Turntable Sentinel

### Prompt A — Turntablism glitch-hop duel

```text
Score the Turntable Sentinel miniboss on the Orbit Line, a huge ranged machine firing hostile note bolts while controlling distance. Exactly 32 beats, 8 bars of 4/4 at 116 BPM, seamless loop, F-sharp minor. Polished 32-bit MIDI glitch-hop and synthetic turntablism: heavy swung drums, wobbling but musical bass, scratch-like pitch-bent synth lead created without sampled voices, chopped electric-piano chords, record-stop effects kept in tempo, brass alarms, and precise note-bolt accents. Give the Sentinel a rotating circular motif while the hero motif cuts across it. Stylish duel, strong groove, readable attacks. Fully instrumental; no MC, vocals, spoken samples, crowd noises, choir, chants, or vocal chops.
```

### Prompt B — Electro-breakbeat sentry

```text
Compose an instrumental boss loop for the Turntable Sentinel. Exactly 32 beats, 8 bars in 4/4 at 140 BPM, seamless loop, F-sharp harmonic minor. Blend MIDI electro-breakbeat, acid bass, cosmic brass, gated snare, rotating arpeggios, turntable-like synth bends, and a sharp keytar melody. The rhythm should feel like a giant platter locking onto the player, with clean wind-up gaps followed by projectile-like musical bursts. Futuristic, playful, threatening, never dirty or chaotic. No vocals, speech, DJ callouts, choir, chants, or voice samples. No fade or final crash.
```

## 18. Stage 2 gameplay — last-stop overload

### Prompt A — Neurofunk arcade rush

```text
Create the late Orbit Line gameplay loop as elite Amp Hounds, Keyboard Centipedes, Drum Wheels, Theremin Jellies, and Vinyl Drones overwhelm the final platform. Exactly 32 beats, 8 bars of 4/4 at 176 BPM, seamless loop, F-sharp minor. Use polished 32-bit MIDI neurofunk-inspired drum and bass without harsh modern noise: precise breakbeats, modulated synth bass, FM electric piano, urgent keytar ostinato, orchestral-synth hits, guitar accents, and a heroic lead line. Communicate that the player’s evolved build is powerful enough to face the full orchestra. Dense momentum with carefully carved SFX space. Instrumental only; no vocal chops, vocals, choir, shouts, speech, or chants.
```

### Prompt B — Progressive cosmic metal

```text
Generate an instrumental final-wave loop for the Orbit Line. Exactly 32 beats, 8 bars in 4/4 at 156 BPM, seamless loop, F-sharp minor. Blend 32-bit MIDI progressive synth-metal, breakbeat, and arcade scoring: palm-muted synthetic guitars, double-kick-style electronic drums, sequenced bass, bright keytar counterpoint, glass bells, and symphonic synth brass. Alternate 4/4 drive with syncopated accents while keeping the actual meter steady and playable. Feel huge, colourful, and triumphant under pressure. No vocals, screams, choir, chanting, crowd sounds, or voice-like guitar effects.
```

## 19. Stage 2 final boss — Grand Orchestrator, phase one

### Prompt A — Mechanical symphonic electro

```text
Score phase one of the Grand Orchestrator, a megazord-like final boss assembled from an alien instrument orchestra at the last Orbit Line platform. Exactly 32 beats, 8 bars of 4/4 at 132 BPM, seamless loop, F-sharp minor with C-minor intrusion. Polished 32-bit MIDI symphonic electro: massive mechanical drums, low orchestral-synth brass, pipe-organ synth, pulsing bass, keytar, metallic tuned percussion, guitar power chords, and rotating arpeggios. Present a new five-note Orchestrator motif, then let the Groove Bound four-note hero motif answer it. Majestic, theatrical, cosmic, readable—not grim realism. Instrumental only; no choir, vocals, chants, robotic speech, vocoder, or human shouts.
```

### Prompt B — Cosmic techno colossus

```text
Compose an instrumental phase-one loop for the Grand Orchestrator boss. Exactly 32 beats, 8 bars in 4/4 at 138 BPM, seamless loop, F-sharp Phrygian. Blend cinematic techno, MIDI progressive rock, and arcade boss music: monumental kick and tom pattern, sequenced bass, organ stabs, wide synth brass, theremin-like instrumental counterline, guitar harmonics, and clockwork percussion referencing both previous minibosses. Make the boss feel assembled from the entire enemy orchestra. Strong attack telegraph gaps, enormous scale, colourful science fantasy. No vocals, choir, chants, speech, robotic announcements, or vocal samples.
```

## 20. Stage 2 final boss — Grand Orchestrator, final phase

### Prompt A — Full-city backing band

```text
Create the final-phase instrumental loop for the Grand Orchestrator battle when the hero’s complete build reaches maximum power. Exactly 32 beats, 8 bars of 4/4 at 176 BPM, seamless loop, modulate between F-sharp minor and C minor before a bright E-flat-major hero flash. Polished 32-bit MIDI maximal fusion: drum-and-bass break, huge but clean synth bass, Joe-style low brass and funk rhythm, Lyra-style keytar and electric guitar, cosmic strings, chiptune sparks, and the four-note Groove Bound motif in a triumphant expanded form. Feel like the whole city is becoming the backing band, without using any actual crowd or voices. High intensity with clear boss-attack space. No vocals, choir, chants, shouts, vocal chops, or spoken words.
```

### Prompt B — Arcade symphonic speedrun finale

```text
Compose a seamless instrumental final-boss climax for Groove Bound. Exactly 32 beats, 8 bars in 4/4 at 168 BPM, F-sharp minor resolving through A major. Blend MIDI symphonic rock, speed breakbeat, cosmic disco, and arcade finale music: rapid drums, driving bass, orchestral-synth brass and strings, keytar lead, harmonized synth guitar, FM bells, and fragments of every major soundtrack motif. Structure bars 1–4 as the Orchestrator’s attack, bars 5–7 as the hero’s answer, and bar 8 as a launch back into bar 1. Exhilarating, colourful, earned, never sentimental. Fully instrumental; no choir, singing, chanting, screams, speech, or vocal-like pads.
```

## 21. Level-up choice screen

### Prompt A — Resonance reward loop

```text
Create a bright instrumental overlay loop for Groove Bound’s paused three-card level-up choice screen. Exactly 32 beats, 8 bars of 4/4 at 120 BPM, seamless loop, E-flat major. Polished MIDI menu funk: clean electric piano, light breakbeat, bouncy bass, marimba, short brass sparkles, and an ascending arpeggio suggesting new possibilities. Exciting but calmer than combat, with plenty of silence around card navigation and confirmation sounds. Include a tiny transformed fragment of the hero motif. No vocals, reward voice, choir, chants, vocal chops, or speech. No dramatic ending.
```

### Prompt B — Tactical arcade choice

```text
Compose an instrumental 32-beat decision loop for selecting a weapon, passive, heal, guard, or coin reward. Use 8 bars of 4/4 at 126 BPM, seamless loop, C Dorian. 32-bit MIDI tactical arcade style: plucked synth, crisp electronic percussion, soft bass sequence, glass bells, muted guitar, and three short melodic options that converge in the final two bars. Feel playful, strategic, and rewarding without rushing the player. No vocals, spoken prompts, choir, chants, or vocal samples; leave space for UI sound effects.
```

## 22. Weapon evolution / fusion

### Prompt A — Resonance transformation

```text
Generate an instrumental evolution cue for fusing a rank-10 weapon with its matching support into an evolved form. Exactly 32 beats, 8 bars of 4/4 at 140 BPM, seamless loop or cleanly cuttable after beat 32, begin in C minor and bloom into E-flat major. Polished 32-bit MIDI transformation music: rising arpeggios, accelerating toms, resonant bass, orchestral-synth brass, keytar glissando, FM bells, and a powerful statement of the Groove Bound motif. Build in four 8-beat stages: recognition, energy gathering, fusion, empowered reveal. Celebratory and arcane, not magical fantasy cliché. Instrumental only; no choir, vocals, chants, spoken weapon names, or vocal effects.
```

### Prompt B — Rave ascension

```text
Create a 32-beat instrumental weapon-evolution cue for Groove Bound. 8 bars of 4/4 at 150 BPM, loopable but with an optional strong cut on beat 32, F-sharp minor to A major. Blend MIDI rave, breakbeat, and arcade transformation music: filtered drums opening into full rhythm, acid-style bass, bright supersaw chords, keytar lead, metallic percussion, and sparkling chiptune accents. Each 8-beat section should add one layer until the final section feels newly overpowered. Avoid a long riser that obscures timing. No vocals, rave shouts, choir, chants, speech, or vocal chops.
```

## 23. Low health / danger layer

### Prompt A — Pulse Tower warning stem

```text
Compose an instrumental low-health danger stem for Groove Bound that can layer over either stage soundtrack. Exactly 32 beats, 8 bars of 4/4 at a tempo-flexible 132 BPM reference, seamless loop, mostly one-note C pulse with transposable minor-second tension. Use sparse 32-bit MIDI elements: muted heartbeat-like kick made only from drums, ticking percussion, filtered bass pulse, high FM warning note, and occasional reversed synth. No full melody and no dense harmony; it must increase urgency without fighting the main music or combat effects. Fully instrumental; no heartbeat recording, breathing, voice, choir, chants, alarms containing speech, or vocal samples.
```

### Prompt B — Critical sync layer

```text
Generate a minimal instrumental critical-health loop designed as an adaptive game-music overlay. Exactly 32 beats, 8 bars of 4/4 at 160 BPM, seamless and easily time-stretched, neutral minor tonality. MIDI electronic percussion, dry rim clicks, low synth throb, narrow-band noise rhythm, two-note dissonant bell, and a faint accelerating arpeggio. It should communicate immediate danger while leaving the base soundtrack clearly recognizable. No vocals, breathing, human heartbeat, choir, chants, speech, or dramatic cinematic boom. Keep the final beat clean for looping.
```

## 24. Pause screen

### Prompt A — Filtered city groove

```text
Create an instrumental pause-menu loop for Groove Bound. Exactly 32 beats, 8 bars of 4/4 at 92 BPM, seamless loop, C minor. Reimagine the active gameplay groove as if heard through a wall: filtered MIDI drums, soft electric bass, Rhodes chords, sparse menu mallets, and a slow fragment of the hero motif. Calm enough for reading settings but still connected to the run. Do not sound sleepy or sad. Fully instrumental with no vocals, speech, choir, chants, humming, or vocal pads. Leave large gaps for menu navigation sounds and avoid a final cadence.
```

### Prompt B — Ambient dub pause

```text
Compose a seamless instrumental pause loop for a neon music-powered arcade roguelike. Exactly 32 beats, 8 bars in 4/4 at 86 BPM, C Dorian. Use polished 32-bit MIDI ambient dub: restrained kick, warm bass, electric piano, delayed synth plucks, soft brass pad, and tiny bit-crushed sparkles. The delays must resolve before the loop point. Reflect temporary safety inside an ongoing supernatural invasion. No vocals, speech, choir, chants, vocal samples, or long reverb tails.
```

## 25. Arsenal Database and build planning

### Prompt A — Synth-funk workshop

```text
Generate an instrumental menu loop for the Arsenal Database, where players inspect 16 weapons, ranks, supports, firing patterns, and evolution recipes. Exactly 32 beats, 8 bars of 4/4 at 114 BPM, seamless loop, E-flat major. Polished 32-bit MIDI synth-funk: tight drum machine, rounded bass, clavinet, electric piano, mallet UI accents, subtle brass, and short rotating lead phrases suggesting different weapon families. Clever, satisfying, organised, and playful—like tuning musical machinery in a workshop. Fully instrumental; no vocals, spoken labels, choir, chants, or voice samples. Keep the mix light for interface effects.
```

### Prompt B — Cosmic jazz loadout

```text
Compose an instrumental loadout and weapon-database loop for Groove Bound. Exactly 32 beats, 8 bars in 4/4 at 108 BPM, seamless loop, F-sharp Dorian. Blend MIDI cosmic jazz, menu electronica, and light breakbeat: fretless synth bass, Rhodes chords, crisp rim and kick, vibraphone, keytar flourishes, and a quiet sequencer. The music should reward experimentation without implying urgency. Add a small harmonic sparkle every 8 beats to support browsing rhythm. No vocals, scatting, choir, chants, speech, or vocal pads.
```

## 26. Admin and debug screens

### Prompt A — Diagnostic minimal techno

```text
Create an instrumental utility loop for Groove Bound’s Admin tuning and debug screens. Exactly 32 beats, 8 bars of 4/4 at 120 BPM, seamless loop, neutral C minor. Polished MIDI minimal techno: dry kick, precise hi-hats, simple sequencer bass, small FM blips, muted chord pulse, and a restrained diagnostic arpeggio. Focused, transparent, and slightly playful, with minimal melody so developers can think while changing stage duration, difficulty, BPM, rewards, and boss tools. Fully instrumental; no computer voice, speech, vocals, choir, chants, or vocal samples. Leave room for UI feedback.
```

### Prompt B — Resonance lab ambience

```text
Compose a seamless instrumental debug-menu loop that feels like inspecting the Resonance network behind Groove Bound. Exactly 32 beats, 8 bars in 4/4 at 100 BPM, C Dorian. Use 32-bit MIDI ambient sequencing: soft electronic percussion, low sine bass, glassy data-like notes, electric piano, tiny modem-like synth gestures without literal modem noise, and a slowly evolving pad. Calm, technical, musical, never ominous. No vocals, synthetic speech, choir, chanting, humming, or vocal pads. No fade-out.
```

## 27. Stage clear and recovery beat

### Prompt A — Street victory sting loop

```text
Create an instrumental stage-clear cue for defeating a major boss and collecting the recovery beat before the campaign continues. Exactly 32 beats, 8 bars of 4/4 at 124 BPM, loopable with an optional clean ending on beat 32, E-flat major. Polished MIDI funk-rock victory music: punchy drums, bass guitar patch, bright brass, keytar, electric guitar, hand percussion, and a confident full statement of the four-note hero motif. Celebrate survival without sounding like the whole game is finished. First 16 beats triumphant, next 8 curious, final 8 ready for the next stage. No vocals, cheers, crowd, choir, chants, or spoken congratulations.
```

### Prompt B — Arcade checkpoint glow

```text
Compose a 32-beat instrumental checkpoint and stage-clear cue for Groove Bound. 8 bars in 4/4 at 132 BPM, seamless loop, E-flat major with a final F-sharp-minor hint. Blend 32-bit MIDI arcade pop, breakbeat, and synth brass: buoyant drums, melodic bass, FM keys, sparkling arpeggio, short guitar lead, and a bright hero motif. Feel earned, colourful, and forward-looking. No vocals, choir, crowd noises, chants, announcer, or vocal chops. Avoid a definitive credits-style ending.
```

## 28. Victory results — Grand Orchestrator defeated

### Prompt A — Backbeat survives

```text
Generate an instrumental victory-results theme after the Grand Orchestrator is defeated and the first movement is interrupted. Exactly 32 beats, 8 bars of 4/4 at 118 BPM, seamless loop, E-flat major with lingering C-minor and F-sharp-minor colours. Polished 32-bit MIDI future-funk anthem: warm drums, celebratory bass, electric piano, brass, keytar, guitar, cosmic strings, and the hero motif shared between Joe and Lyra’s instrumental colours. Proud and joyful, but include one unresolved alien chord in bar 7 to show the story is not over. Fully instrumental; no choir, vocals, cheering, chants, speech, or vocal samples.
```

### Prompt B — Cosmic arcade triumph

```text
Compose an instrumental results-screen victory loop for Groove Bound. Exactly 32 beats, 8 bars in 4/4 at 126 BPM, seamless loop, A major moving to E-flat major through colourful game-music harmony. Blend MIDI orchestral arcade, synthwave, and breakbeat: heroic brass, strings, punchy electronic drums, octave bass, keytar lead, FM bells, and restrained chiptune flourishes. Recap the title motif in a larger, warmer form, then leave a subtle cliffhanger on the last two beats. No vocals, choir, spoken score callouts, cheers, chants, or vocal pads.
```

## 29. Defeat and run results

### Prompt A — Broken groove, ready to retry

```text
Create an instrumental defeat-results loop for Groove Bound after the hero falls. Exactly 32 beats, 8 bars of 4/4 at 84 BPM, seamless loop, C minor. Polished 32-bit MIDI trip-hop: dusty slow beat, subdued bass, detuned electric piano, soft music-box synth, muted brass, and a broken version of the four-note hero motif that finds a small upward turn in the final bar. Disappointed but encouraging, never tragic or punishing; the player should want to restart. Fully instrumental; no vocals, sighs, choir, chants, speech, heartbeat, or vocal samples.
```

### Prompt B — Signal lost, pulse remains

```text
Compose a seamless instrumental game-over loop for a playful cosmic music roguelike. Exactly 32 beats, 8 bars in 4/4 at 76 BPM, C minor with a final suspended E-flat-major note. Use MIDI ambient breakbeat, low synth bass, sparse piano, glass bells, distant radio-like synth noise without speech, and a quiet pulse that never stops. Suggest the Resonance signal was interrupted, not destroyed. No vocals, whispers, choir, spoken message, chants, humming, or vocal pads. No melodramatic final chord.
```

## 30. Ending cutscene — Grand Conductor / future teaser

### Prompt A — The orchestra is still assembling

```text
Score Groove Bound’s ending cutscene after victory, when the distant Grand Conductor declares the first movement incomplete and begins assembling a larger orchestra. Exactly 32 beats, 8 bars of 4/4 at 96 BPM, seamless cinematic loop, begin in E-flat major and let altered C minor take over. Polished 32-bit MIDI cosmic jazz and orchestral electronica: Rhodes chords, slow breakbeat, low synth brass, glassy arpeggios, organ, distant metallic percussion, and the hero motif answered by a new ominous Conductor motif. Balance earned hope, playful defiance, and a clear sequel hook. Dialogue-friendly and fully instrumental; no spoken villain line, vocals, choir, chants, whispers, or vocal samples.
```

### Prompt B — Neon cliffhanger credits

```text
Compose an instrumental future-teaser loop for the final Groove Bound cutscene. Exactly 32 beats, 8 bars in 4/4 at 108 BPM, seamless loop, C minor with E-flat-major resistance. Blend MIDI synthwave, cinematic breakbeat, keytar rock, and space ambience: pulsing bass, gated drums, electric piano, restrained guitar, cosmic bells, synth brass, and a final transformed statement of the title motif. Bars 1–4 celebrate surviving the first movement; bars 5–7 reveal a much larger cosmic signal; bar 8 turns confident and loops into the beginning. No vocals, spoken dialogue, robotic voice, choir, chants, or vocal-like pads.
```

---

## Production and implementation notes

1. Generate at least three takes from both prompt routes for each cue before choosing a direction.
2. Keep every chosen cue as an exact 8-bar module. Export versions with a two-beat count-in only for editing; do not include the count-in in the game file.
3. For gameplay cues, ask for five aligned exports when possible: full mix, drums, bass, harmony, and melody/tension. This makes later BeatClock intensity changes possible without replacing the composition.
4. Make Stage 1 cues share drum and bass timbres; make Stage 2 cues share FM bells, orbiting arpeggios, and wider synth space. Reuse the same four-note hero motif across both worlds.
5. Boss music should preserve attack readability. Avoid nonstop fills, uncontrolled sub-bass, and loud impacts on every beat.
6. Export a clean loop in WAV for mastering and OGG for the LÖVE runtime. Check the transition from beat 32 to beat 1 ten times without a click, gap, reverb jump, or rhythm stumble.
7. Treat generated results as source candidates. Record the generator, model/version, date, seed if available, prompt, and editing history before promoting any cue into the canonical runtime.
