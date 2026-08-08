# Groove Bound — Seedance 2.5 Cutscene Video Prompts

## Purpose

This is the complete reference-to-video prompt set for replacing Groove Bound's
five current illustrated cutscenes with full-screen 16:9 video backgrounds. Each
cutscene has a 15-second and a 30-second version. Every version preserves the
current canon dialogue verbatim, uses the current soundtrack cue, generates
synchronised voiceover and sound effects, and forbids all visible text.

The target look is the game's existing cinematic artwork: detailed 16-bit-style
pixel art with crisp 8-bit-era pixel discipline, chunky clusters, hard-edged
lighting, strong dark outlines, and limited neon colour ramps. It must never
drift into smooth vector animation, 3D CGI, photorealism, anime line art, or
modern painterly illustration.

## Seedance production note

ByteDance's currently public Seedance documentation verifies multimodal
reference-to-video with text, images, video and audio; up to nine image, three
video and three audio references; 15-second multi-shot audiovisual output; and
prompted video extension. These prompts use that official `@Image` / `@Audio`
reference pattern and are labelled for the requested Seedance 2.5 workflow. If
the interface does not offer a native 30-second duration, generate the first 15
seconds and use **Extend** for the second 15 seconds with the continuation
instruction supplied in the 30-second prompt.

Official references:

- [Seedance 2.0 official launch](https://seed.bytedance.com/en/blog/official-launch-of-seedance-2-0)
- [Seedance model page](https://seed.bytedance.com/en/seedance2_0)

## Current-cutscene and lore audit

| Scene ID | Current static beats | Canon function | Video direction |
|---|---|---|---|
| `prologue` | Nightlife, the Break, emergency, heroes answer | Establish Backbeat, Resonance infrastructure, Pulse Tower and the invasion | Start joyful and alive, rupture violently, finish with forward heroic momentum |
| `joe_intro` | Joe commits; Lyra coordinates | Define Joe as the grounded protector and complementary half of the team | Weighty close combat, firm camera, protective blocking, warm street energy |
| `lyra_intro` | Lyra takes the invasion personally; Joe covers her | Define Lyra as the fast risk-taking Live Wire | Faster cutting, keytar movement, rooftop traversal, playful danger |
| `stage2_transition` | First Press, musical map, dead Orbit Line | Connect Static Baron's defeat to Stage 2 without losing build continuity | Investigation becomes a kinetic descent into a cosmic rail chase |
| `ending` | Conductor signal, Joe and Lyra answer | Reveal that the Grand Orchestrator was only the first movement | Show the Orchestrator defeated locally; keep the Grand Conductor distant and unrevealed |

## Shared constraints for every generation

- Output: exactly 16:9 landscape, 1920×1080 preferred, full-bleed composition,
  no letterboxing and no baked UI. Keep key action inside the central 90% safe
  area so the game can crop modestly at other aspect ratios.
- Reference fidelity: preserve Joe and Lyra's faces, skin tone, hair, clothing,
  body proportions, signature weapons and pixel rendering from the supplied
  character references. Do not redesign or age either character.
- Pixel rendering: detailed cinematic 16-bit pixel art, nearest-neighbour-feel
  edges, stable pixel-grid scale, crisp clusters, stepped gradients, controlled
  dithering and two-to-four-frame smear accents. No sub-pixel shimmer, crawling
  outlines, texture boiling, morphing faces, extra fingers, fused instruments or
  costume changes.
- Palette: deep indigo and black foundations; cyan, teal, magenta and violet
  energy; gold and warm red hero accents. Bright, playful arcade spectacle with
  supernatural cosmic tension, never grim realism or gore.
- Camera: coherent multi-shot storytelling, motivated cuts on beats, readable
  staging, strong silhouettes, foreground parallax, punch-in close-ups and fast
  tracking only when specified. No random camera orbit, drone footage, fake
  handheld realism or disorienting motion blur.
- Dialogue: use the exact quoted words, in the exact order, with clean English
  pronunciation and accurate mouth movement. Never paraphrase, add, omit or
  repeat a word. Only the named speaker speaks. No improvised reactions,
  background chatter, singing, chanting or vocal chops.
- Voice continuity: Joe is a young-adult masculine voice, warm, grounded,
  medium-low and wry; Lyra Vex is a young-adult feminine voice, bright,
  confident, lightly raspy and playful; the Narrator is warm, cinematic and
  measured; the Emergency Broadcast is urgent, neutral and radio-filtered; the
  Grand Conductor is an immense distant synthetic bass voice built from layered
  speaker resonance, clearly intelligible and not shouted.
- Audio: use the supplied project track as the background score and synchronise
  cuts, impacts and movement to its beat. Preserve the score's instrumental
  identity. Duck music under speech, keep voice centred, and place ambience and
  foley in stereo around it. No replacement song and no newly generated vocals.
- Absolute text ban: no titles, captions, subtitles, speech bubbles, credits,
  lyrics, logos, HUD, menus, labels, numbers, readable signs, broadcast text,
  watermark or typography of any kind. Communicate the emergency and musical
  map visually through icons, light and motion only.

---

## 1. Prologue — The Night the Sky Missed a Beat

### Reference upload map

- `@Image 1` — `assets/generated/cutscenes/prologue-atlas.png` — authoritative
  four-panel storyboard, palette and composition reference.
- `@Image 2` — `assets/generated/campaign/character-portraits-atlas.png` — Joe
  and Lyra face, costume and weapon identity.
- `@Image 3` — `assets/generated/campaign/joe-action-sheet.png` — Joe movement
  and body proportions.
- `@Image 4` — `assets/generated/campaign/joe-talking-strip.png` — Joe's stable
  speaking face and mouth states.
- `@Image 5` — `assets/generated/campaign/backbeat-environment-expansion-atlas.png`
  — Backbeat street props and palette.
- `@Image 6` — `assets/generated/environment-atlas.png` — stage, speaker and
  concert-equipment vocabulary.
- `@Image 7` — `assets/generated/enemy-variants-atlas.png` — Stage 1 invader
  silhouettes, including the Metronome Guardian and Static Baron.
- `@Audio 1` — `assets/music/02_prologue_city.ogg` — opening city cue.
- `@Audio 2` — `assets/music/03_prologue_break.ogg` — cosmic rupture cue.
- `@Audio 3` — `assets/music/04_prologue_resolve.ogg` — emergency and hero
  resolve cue.

### 15-second variation

```text
Create an exact 15-second, 16:9, multi-shot audiovisual cutscene for Groove Bound. Reference chain: @Image 1 ++ @Image 2 ++ @Image 3 ++ @Image 4 ++ @Image 5 ++ @Image 6 ++ @Image 7 ++ @Audio 1 ++ @Audio 2 ++ @Audio 3. Use Image 1 as the authoritative four-beat storyboard and visual style. Use Images 2, 3 and 4 to keep Joe perfectly on-model. Use Images 5 and 6 for Backbeat's neon rooftops, alleys, concert infrastructure and Pulse Tower. Use Image 7 for the invading instrument-machine silhouettes. Preserve detailed cinematic 16-bit pixel art with crisp 8-bit pixel discipline, stable chunky clusters, dark outlines, stepped neon lighting and limited dithering. This is animated pixel art, never 3D, photoreal, vector, anime, painterly or smooth high-frame-rate illustration.

Music source and path: use Audio 1 from `assets/music/02_prologue_city.ogg` from 00:00-00:04, beat-cut into Audio 2 from `assets/music/03_prologue_break.ogg` from 00:04-00:08, then resolve into Audio 3 from `assets/music/04_prologue_resolve.ogg` from 00:08-00:15. Preserve the supplied instrumental cues, make the transitions musical, and duck them beneath speech.

00:00-00:04 — Begin with a fast descending crane shot over a joyful Backbeat night: rooftop players, train lights, dancing crowds, pulsing speaker stacks and the distant Pulse Tower all moving on one shared beat. Warm cyan, teal, magenta and gold light ripple through the city. Narrator, warm and brisk but fully intelligible, says exactly: "Backbeat never slept. Every rooftop, train line, and alley carried a piece of the city's song."

00:04-00:08 — On a hard reverse-snare cut, every speaker cone sucks inward. The city groove reverses, lights stutter backwards and a huge violet cosmic chord tears open the sky. Instrument-machine invaders dive through the rift as the camera whip-pans from speaker to speaker. Narrator says exactly: "Then the Break arrived—a cosmic chord played backwards through every speaker at once."

00:08-00:11.5 — Smash to Pulse Tower going dark. A red emergency beacon pulses without any letters or symbols while speaker robots assemble in the streets. A radio-filtered Emergency Broadcast voice says exactly: "Pulse Tower offline. Instrument-class invaders assembling. All Resonance-bound citizens: answer the downbeat."

00:11.5-00:15 — Joe lands in a three-point stance on a rain-bright rooftop, raises his gold-and-cyan Kazoo Pistol, fires one blue resonance ring through an attacking robot, then sprints toward the city edge as the camera tracks low beside him. Joe says exactly, with grounded defiance: "The universe wants an encore? Fine. Let's make it loud enough to remember us." End on Joe leaping forward into cyan light, creating a clean action match into gameplay.

Synchronised sound effects: living crowd and train rhythm at the opening; speaker-cone thumps; reversed electrical suction; cosmic tear crack; emergency-radio static; tower power-down bass hit; robot servos; Joe's landing impact; Kazoo Pistol brass-pop and resonance-ring whoosh. Keep all foley pixel-arcade stylised, punchy and stereo-positioned.

No visible words anywhere: no title, captions, subtitles, speech bubbles, emergency text, readable signs, logo, HUD, credits or watermark. No extra dialogue. No lip-sync on the Narrator or Emergency Broadcast. Joe alone lip-syncs his final line. Do not show the Grand Orchestrator or Grand Conductor in this prologue.
```

### 30-second variation

```text
Create an exact 30-second, 16:9, multi-shot audiovisual cutscene for Groove Bound. Reference chain: @Image 1 ++ @Image 2 ++ @Image 3 ++ @Image 4 ++ @Image 5 ++ @Image 6 ++ @Image 7 ++ @Audio 1 ++ @Audio 2 ++ @Audio 3. Use Image 1 as the authoritative four-beat storyboard and visual style; use Images 2, 3 and 4 for exact Joe identity, motion and lip-sync; use Images 5 and 6 for Backbeat; and use Image 7 for the Stage 1 instrument-machine invasion. Render detailed cinematic 16-bit pixel art with strict 8-bit-era pixel discipline, stable pixel-grid scale, crisp outlines, deliberate stepped lighting and energetic sprite-like smear frames. Never become 3D, photoreal, vector, anime or painterly.

Music source and path: Audio 1 is `assets/music/02_prologue_city.ogg` for 00:00-00:08; Audio 2 is `assets/music/03_prologue_break.ogg` for 00:08-00:15; Audio 3 is `assets/music/04_prologue_resolve.ogg` for 00:15-00:30. Cut and crossfade only on musical beats, preserve the supplied melodies, and duck the score under every spoken line.

00:00-00:08 — Open on a speaker cone breathing to the beat, pull back through a rooftop show, follow a lit train through alleys, then rise into a wide view of Backbeat and Pulse Tower. The city feels playful, communal and alive; music is infrastructure, so traffic lights, rail pulses and stage lighting visibly share one rhythm. Narrator says exactly: "Backbeat never slept. Every rooftop, train line, and alley carried a piece of the city's song."

00:08-00:15 — A needle-scratch freezes the crowd for one pixelated anticipation frame. The beat reverses. Camera races backwards through the previous route as every speaker implodes with violet light, then tilts up into a cosmic tear. Instrument-machine invaders drop in readable silhouettes while Joe and Lyra look up from separate rooftops. Narrator says exactly: "Then the Break arrived—a cosmic chord played backwards through every speaker at once."

00:15-00:22 — Pulse Tower blacks out section by section. Fast inserts show transit gates failing, hostile metronome limbs locking into time and citizens taking cover. An abstract red pulse ring conveys the alert without any written interface. A radio-filtered Emergency Broadcast voice says exactly: "Pulse Tower offline. Instrument-class invaders assembling. All Resonance-bound citizens: answer the downbeat."

00:22-00:30 — Joe enters at street level, shields two civilians from a soundwave, slides beneath a mechanical strike, plants his feet and fires his gold-and-cyan Kazoo Pistol. The resonance blast pushes the invader through a speaker barricade. Push into Joe's stable on-model face as he says exactly: "The universe wants an encore? Fine. Let's make it loud enough to remember us." He turns and charges toward Pulse Tower with Lyra appearing on a parallel rooftop in the far background. Finish on a forward-moving match cut suitable for gameplay.

Synchronised sound effects: crowd groove, train rail clack, rooftop cable hum, reverse record pull, speaker suction, cosmic-rift crack, descending robot thrusters, power-grid shutdown, alarm pulse without spoken words, radio static, robot servo impacts, Joe's slide and landing, Kazoo Pistol pop, blue resonance blast and debris. Sound stays stylised, musical and clean beneath dialogue.

No visible text of any kind: no title, subtitle, caption, speech bubble, emergency copy, readable sign, logo, UI, credits or watermark. Do not paraphrase or add dialogue. Narrator and broadcast are off-screen. Only Joe lip-syncs. Keep the local threats to Stage 1 silhouettes; do not reveal the Grand Orchestrator or Grand Conductor.

If native 30-second generation is unavailable: generate 00:00-00:15 first, then extend exactly 15 seconds from the cosmic-tear frame. Preserve the same pixel grid, palette, characters, camera direction and Audio 3 transition; continue with Pulse Tower shutdown and Joe's complete resolve beat without recapping earlier shots.
```

---

## 2. Joe Intro — The Backbeat

### Reference upload map

- `@Image 1` — `assets/generated/campaign/character-portraits-atlas.png` — Joe
  and Lyra identity and costume.
- `@Image 2` — `assets/generated/campaign/joe-action-sheet.png` — Joe's grounded
  movement language.
- `@Image 3` — `assets/generated/campaign/joe-talking-strip.png` — Joe lip-sync
  and facial stability.
- `@Image 4` — `assets/generated/campaign/lyra-action-sheet.png` — Lyra's
  movement and silhouette.
- `@Image 5` — `assets/generated/campaign/lyra-talking-strip.png` — Lyra lip-sync
  and facial stability.
- `@Image 6` — `assets/generated/cutscenes/prologue-atlas.png` — Backbeat
  cinematic palette and invasion context.
- `@Image 7` — `assets/generated/campaign/backbeat-environment-expansion-atlas.png`
  — Backbeat street props.
- `@Image 8` — `assets/generated/enemy-variants-atlas.png` — Stage 1 enemies.
- `@Audio 1` — `assets/music/06_joe_intro.ogg` — Joe's heavy street-funk cue.

### 15-second variation

```text
Create an exact 15-second, 16:9 Joe character-intro cutscene for Groove Bound. Reference chain: @Image 1 ++ @Image 2 ++ @Image 3 ++ @Image 4 ++ @Image 5 ++ @Image 6 ++ @Image 7 ++ @Image 8 ++ @Audio 1. Use Images 1, 2 and 3 to keep Joe perfectly on-model: warm brown skin, black textured hair, teal bomber jacket with gold waveform details, black shirt and trousers, red-and-white shoes, blue Resonance device and gold-and-cyan Kazoo Pistol. Use Images 4 and 5 for exact Lyra identity. Use Images 6 and 7 for Backbeat's neon streets and Image 8 for Stage 1 enemy silhouettes. Detailed cinematic 16-bit pixel art with crisp 8-bit pixel discipline, stable scale and punchy sprite-animation timing; never 3D, photoreal, vector, anime or painterly.

Music source and path: use Audio 1 from `assets/music/06_joe_intro.ogg` for the full 00:00-00:15, preserving its heavy street-funk identity. Cut movement and impacts to the beat and duck the music beneath dialogue.

00:00-00:06.8 — Low tracking shot beside Joe's red shoes as he runs down a speaker-lined alley toward Pulse Tower. He shoulder-checks a drum robot away from fleeing civilians, plants himself at the centre intersection, raises the Kazoo Pistol and holds the line against an incoming soundwave. Push to an on-model speaking close-up. Joe says exactly: "I know these streets. If the noise wants Backbeat, it comes through me first."

00:06.8-00:13.3 — Lyra lands on an overhead rail, deflects a hostile note with her keytar, then points toward the distant violet signal while Joe continues guarding the centre. The camera racks from Joe in the foreground to Lyra above him. Lyra says exactly: "Hold the centre, Joe. I'll chase the signal. Same song, different parts."

00:13.3-00:15 — Joe gives one confident half-smile, braces against a second shockwave and fires a circular cyan-gold blast directly down the street. End on a strong forward silhouette with clear space for the transition into Stage 1 gameplay.

Synchronised sound effects: running footfalls, jacket snap, robot servo clank, bassy shield impact, Kazoo Pistol brass-pop, resonance ring, Lyra rail landing and keytar chord slash. Keep voices clear and centred.

No text: no character name, title card, subtitles, captions, speech bubbles, logo, HUD, readable signs, credits or watermark. Exact dialogue only. Joe and Lyra each lip-sync only their own line. No costume or weapon swaps, no extra heroes, no gore.
```

### 30-second variation

```text
Create an exact 30-second, 16:9 Joe character-intro cutscene for Groove Bound. Reference chain: @Image 1 ++ @Image 2 ++ @Image 3 ++ @Image 4 ++ @Image 5 ++ @Image 6 ++ @Image 7 ++ @Image 8 ++ @Audio 1. Use Images 1, 2 and 3 as strict Joe identity, costume, movement and mouth-shape references; Images 4 and 5 as strict Lyra references; Images 6 and 7 for Backbeat; and Image 8 for Stage 1 robots. Preserve detailed cinematic 16-bit pixel art with crisp 8-bit pixel discipline, stable chunky clusters, dark outlines and limited neon ramps. Keep action readable and physical, never smooth 3D, live action, vector, anime or painterly animation.

Music source and path: use Audio 1 from `assets/music/06_joe_intro.ogg` continuously from 00:00-00:30. Preserve the supplied instrumental track, restart or loop it only on its authored beat boundary, duck beneath dialogue and align hits to its heavy street-funk rhythm.

00:00-00:07 — Establish Joe's relationship with the city in three beat-matched shots: he runs past familiar rooftop cables, slides beneath a closing transit barrier and catches a falling speaker case before it hits civilians. His motion is powerful, efficient and grounded rather than acrobatic.

00:07-00:15 — Joe reaches the centre intersection as three instrument robots converge. He knocks one back with a guarded shoulder, blocks a soundwave behind his forearm device and levels the Kazoo Pistol. Camera arcs only 45 degrees, keeping his silhouette readable. Joe says exactly: "I know these streets. If the noise wants Backbeat, it comes through me first."

00:15-00:23 — A cyan keytar chord cuts across the frame. Reveal Lyra sprinting along an elevated rail toward the violet signal. She looks down at Joe, points ahead, then launches over a gap while saying exactly: "Hold the centre, Joe. I'll chase the signal. Same song, different parts."

00:23-00:30 — Intercut their complementary roles on the beat: Joe anchors the street and pushes the horde back with expanding brass rings; Lyra races across rooftops after the signal. Finish with a split-depth composition—Joe large in foreground, Lyra small but clear in the distance—then Joe charges toward camera into a clean gameplay match cut.

Synchronised sound effects: urban rail rhythm, running shoes, speaker-case weight, barrier slam, robot gears, shield thump, Kazoo Pistol pop and expanding resonance, Lyra's keytar chord and landing. Use stylised arcade foley, not realistic gunfire.

No visible words of any kind: no title, name, captions, subtitles, speech bubbles, logo, HUD, sign text, credits or watermark. Use exact dialogue only, correctly assigned and accurately lip-synced. No extra dialogue, costume drift, weapon replacement, duplicated characters or gore.

If native 30-second generation is unavailable: generate 00:00-00:15 through Joe's complete line, then extend 15 seconds from the incoming cyan keytar chord. Preserve Joe, camera direction and track continuity; reveal Lyra, deliver her exact full line and finish with the complementary-role montage.
```

---

## 3. Lyra Vex Intro — The Live Wire

### Reference upload map

- `@Image 1` — `assets/generated/campaign/character-portraits-atlas.png` — Lyra
  and Joe identity and costume.
- `@Image 2` — `assets/generated/campaign/lyra-action-sheet.png` — Lyra's fast
  movement language.
- `@Image 3` — `assets/generated/campaign/lyra-talking-strip.png` — Lyra lip-sync
  and facial stability.
- `@Image 4` — `assets/generated/campaign/joe-action-sheet.png` — Joe movement.
- `@Image 5` — `assets/generated/campaign/joe-talking-strip.png` — Joe lip-sync.
- `@Image 6` — `assets/generated/cutscenes/prologue-atlas.png` — rooftop-show and
  invasion visual language.
- `@Image 7` — `assets/generated/campaign/backbeat-environment-expansion-atlas.png`
  — Backbeat environment props.
- `@Image 8` — `assets/generated/enemy-variants-atlas.png` — Stage 1 robots.
- `@Audio 1` — `assets/music/07_lyra_intro.ogg` — Lyra's electro-rock keytar
  cue.

### 15-second variation

```text
Create an exact 15-second, 16:9 Lyra Vex character-intro cutscene for Groove Bound. Reference chain: @Image 1 ++ @Image 2 ++ @Image 3 ++ @Image 4 ++ @Image 5 ++ @Image 6 ++ @Image 7 ++ @Image 8 ++ @Audio 1. Use Images 1, 2 and 3 to keep Lyra perfectly on-model: warm brown skin, cyan-and-magenta asymmetrical swept hair with shaved side detail, purple jacket with cyan waveform marks, black waveform shirt, dark trousers, purple shoes, blue Resonance device and neon purple-cyan keytar. Use Images 4 and 5 for exact Joe identity. Use Images 6 and 7 for the rooftop-show Backbeat setting and Image 8 for invading robots. Detailed cinematic 16-bit pixel art with crisp 8-bit pixel discipline and stable pixel clusters; never 3D, photoreal, vector, anime or painterly.

Music source and path: use Audio 1 from `assets/music/07_lyra_intro.ogg` for the full 00:00-00:15. Preserve the supplied fast electro-rock keytar track, cut on its beat and duck it under speech.

00:00-00:06.7 — A rooftop show's lights explode into violet static as robots crash through speaker stacks. Lyra swings under a lighting truss, lands in a knee slide, catches her keytar and fires a cyan-magenta chord that knocks two robots apart. Push into her playful, furious on-model close-up as Lyra says exactly: "Alien robots crashed my favourite rooftop show. I am taking that personally."

00:06.7-00:13.4 — Lyra vaults over an amplifier, wall-runs past a hostile pulse and leaps toward the next roof. Joe appears below, plants his feet and blasts open a safe route through the alley. Looking up with a wry smile, Joe says exactly: "Fast feet, loud strings. I'll keep the exit open—just try not to steal every spotlight."

00:13.4-00:15 — Lyra answers only with a silent grin, spins the keytar into playing position and launches from the rooftop as a bright chord becomes the match cut into gameplay.

Synchronised sound effects: speaker crash, truss cable whip, fast landing scrape, keytar chord slash, robot metal impacts, amplifier vault, wall-run steps, Joe's Kazoo Pistol pop and Lyra's final launch whoosh. Music remains dominant between lines but ducks cleanly beneath both voices.

No text: no character name, title, subtitle, caption, speech bubble, logo, HUD, readable venue sign, credits or watermark. Exact dialogue only. Lyra and Joe lip-sync only their own lines. Lyra does not speak an extra comeback. No instrument morphing, duplicated limbs, costume drift or gore.
```

### 30-second variation

```text
Create an exact 30-second, 16:9 Lyra Vex character-intro cutscene for Groove Bound. Reference chain: @Image 1 ++ @Image 2 ++ @Image 3 ++ @Image 4 ++ @Image 5 ++ @Image 6 ++ @Image 7 ++ @Image 8 ++ @Audio 1. Use Images 1, 2 and 3 as strict references for Lyra's identity, costume, keytar, motion and lip-sync; Images 4 and 5 for Joe; Images 6 and 7 for Backbeat's rooftop music culture; and Image 8 for Stage 1 enemies. Render detailed cinematic 16-bit pixel art with crisp 8-bit pixel discipline, stable pixel-grid scale, strong dark outlines, stepped neon light and purposeful smear frames. Never turn into 3D CGI, live action, vector art, anime or painterly animation.

Music source and path: use Audio 1 from `assets/music/07_lyra_intro.ogg` continuously from 00:00-00:30. Preserve the supplied 142 BPM electro-rock keytar cue; because its runtime loop is shorter than 15 seconds, repeat only at its exact authored loop boundary, with no audible seam. Duck under dialogue and align Lyra's movement to its fast accents.

00:00-00:07 — Begin inside a vibrant rooftop show from Lyra's point of view: fingers on keytar, crowd bouncing, lights in rhythm. The sky tears open. Instrument robots crash through the truss and the crowd scatters. Lyra protects the nearest fans by kicking an amp case into a robot's path and swinging from a cable over the impact.

00:07-00:15 — Lyra lands, catches her keytar, slides under a trumpet blast and answers with a broad cyan-magenta chord. Two robots tumble through pixel-art speaker debris. Push into her stable face as she says exactly: "Alien robots crashed my favourite rooftop show. I am taking that personally."

00:15-00:23 — A fast side-scrolling-style tracking shot follows Lyra across three rooftops: amplifier vault, wall run, rail grind, then a long gap jump. Below, Joe shields the exit alley and fires circular Kazoo Pistol rings through the pursuing enemies. Joe says exactly: "Fast feet, loud strings. I'll keep the exit open—just try not to steal every spotlight."

00:23-00:30 — Lyra gives a silent over-the-shoulder grin, kicks off a neon speaker, spins once in a controlled sprite-smear arc and lands on the next roof already playing. Her chord briefly draws a cyan path toward Pulse Tower. End with Lyra charging along that path into a clean gameplay match cut while Joe holds the route behind her.

Synchronised sound effects: crowd and stage hum, cosmic impact, truss snap, amp-case skid, cable swing, landing, trumpet pulse, keytar chord slashes, robot debris, roof footsteps, rail grind, Joe's Kazoo Pistol pop and final launch whoosh. Maintain clear dialogue and stereo action placement.

No visible text of any kind: no title, name, subtitle, caption, speech bubble, lyric, logo, HUD, readable sign, credits or watermark. Exact dialogue only and correctly lip-synced. No improvised reply from Lyra, no singing, no extra heroes, no changing clothes or weapons, no gore.

If native 30-second generation is unavailable: generate 00:00-00:15 through Lyra's complete line, then extend 15 seconds from her first rooftop sprint. Preserve her speed direction, exact character model and Audio 1 loop; reveal Joe, deliver his complete exact line and finish on Lyra's forward gameplay match cut.
```

---

## 4. Stage 2 Transition — The First Press

### Reference upload map

- `@Image 1` — `assets/generated/cutscenes/campaign-atlas.png` — authoritative
  First Press, map, Orbit Line and final-threat storyboard.
- `@Image 2` — `assets/generated/campaign/character-portraits-atlas.png` — Joe
  and Lyra identity.
- `@Image 3` — `assets/generated/campaign/joe-action-sheet.png` — Joe movement.
- `@Image 4` — `assets/generated/campaign/lyra-action-sheet.png` — Lyra movement.
- `@Image 5` — `assets/generated/campaign/backbeat-environment-expansion-atlas.png`
  — ruined Stage 1 setting.
- `@Image 6` — `assets/generated/campaign/stage2-environment-atlas.png` — Orbit
  Line machines, transit carriage and First Press forms.
- `@Image 7` — `assets/generated/campaign/orbit-environment-expansion-atlas.png`
  — Orbit Line architecture and props.
- `@Image 8` — `assets/generated/campaign/stage2-enemies-atlas.png` — distant
  Stage 2 enemy silhouettes only.
- `@Audio 1` — `assets/music/13_first_press.ogg` — discovery/map cue.
- `@Audio 2` — `assets/music/14_dead_line_recovery.ogg` — descent/recovery cue.

### 15-second variation

```text
Create an exact 15-second, 16:9 Stage 1-to-Stage 2 transition cutscene for Groove Bound. Reference chain: @Image 1 ++ @Image 2 ++ @Image 3 ++ @Image 4 ++ @Image 5 ++ @Image 6 ++ @Image 7 ++ @Image 8 ++ @Audio 1 ++ @Audio 2. Use Image 1 as the authoritative story sequence: First Press recovered, musical map activated, abandoned Orbit Line entered. Use Images 2, 3 and 4 to keep Joe and Lyra perfectly on-model. Use Image 5 for the shattered Backbeat battlefield and Images 6 and 7 for the Orbit Line. Use Image 8 only for brief distant enemy silhouettes. Detailed cinematic 16-bit pixel art with crisp 8-bit pixel discipline, stable chunky clusters and readable action; never 3D, photoreal, vector, anime or painterly.

Music source and path: use Audio 1 from `assets/music/13_first_press.ogg` from 00:00-00:10, then beat-crossfade to Audio 2 from `assets/music/14_dead_line_recovery.ogg` from 00:10-00:15. Preserve both supplied instrumental cues and duck them beneath dialogue.

00:00-00:05 — In the smoking shell of the defeated Static Baron, Lyra catches the glowing First Press record before it hits the ground. It unfolds into rotating grooves and a cyan-violet constellation route around her and Joe, never forming letters or labels. Lyra says exactly: "That record was inside the Baron's core. It isn't music—it is a map pretending to be music."

00:05-00:10 — The camera dives through the projected groove-map, races beneath Backbeat's streets and reveals a sealed orbital rail platform powering on after years of darkness. Joe traces the signal downward with his Kazoo Pistol light and says exactly: "The signal dives below Backbeat. Orbit Line. Closed for years, still broadcasting to the stars."

00:10-00:15 — Lyra kicks the chained transit gate open as an abandoned rail carriage sparks alive. Joe and Lyra sprint, leap aboard and defend the doorway from one last robot as the train drops into a cosmic tunnel. Lyra says exactly: "Then we ride the dead line. Whatever is conducting this invasion is waiting at the last stop." End looking forward through the carriage window at the impossible cyan-violet Orbit Line.

Synchronised sound effects: Static Baron core cooling, metal shell release, vinyl lift and needle shimmer, holographic groove pulses, underground power relay, gate-chain snap, train ignition, rail clack, enemy servo, Kazoo pop, keytar slash and cosmic tunnel rush. Sound stays musical and clean beneath the rapid exact dialogue.

No visible words: no scene title, map labels, station name, signs, subtitles, captions, speech bubbles, logo, HUD, credits or watermark. The map is entirely abstract light and constellation geometry. Exact dialogue only. Do not show the Grand Conductor yet. Do not resurrect the Static Baron or reset either hero's equipment.
```

### 30-second variation

```text
Create an exact 30-second, 16:9 Stage 1-to-Stage 2 transition cutscene for Groove Bound. Reference chain: @Image 1 ++ @Image 2 ++ @Image 3 ++ @Image 4 ++ @Image 5 ++ @Image 6 ++ @Image 7 ++ @Image 8 ++ @Audio 1 ++ @Audio 2. Use Image 1 as the authoritative four-panel visual story; Images 2, 3 and 4 as strict Joe and Lyra identity and movement references; Image 5 for the defeated Static Baron arena; Images 6 and 7 for the Orbit Line; and Image 8 only for distant Stage 2 threat silhouettes. Render detailed cinematic 16-bit pixel art with crisp 8-bit pixel discipline, stable pixel scale, dark outlines, controlled dithering and energetic but readable camera movement. Never become 3D CGI, live action, vector, anime or painterly animation.

Music source and path: Audio 1 is `assets/music/13_first_press.ogg` for 00:00-00:19; Audio 2 is `assets/music/14_dead_line_recovery.ogg` for 00:19-00:30. Preserve the supplied instrumental tracks, change cue on a beat as the rail gate opens, and duck under all dialogue.

00:00-00:09 — Begin on the Static Baron's giant speaker body collapsing. Joe braces against the shockwave while Lyra runs up fallen armour, reaches into the cooling turntable core and pulls out the glowing First Press record. In close-up, concentric grooves rotate above her hand and project a constellation route around both heroes. Lyra says exactly: "That record was inside the Baron's core. It isn't music—it is a map pretending to be music."

00:09-00:18 — Track the projected route as it threads between Backbeat buildings, dives into a sealed stairwell and continues beneath the city. Joe and Lyra follow at a run. They stop above a vast dark station; Joe's Kazoo Pistol light sweeps across dead rails, alien amplifier growth and an old suspended train. Joe says exactly: "The signal dives below Backbeat. Orbit Line. Closed for years, still broadcasting to the stars."

00:18-00:26 — The First Press locks into an unlabelled turntable console. On the music transition, light races down the rails and the station opens into impossible outer space. Lyra strikes a chord that breaks the transit-gate chains, then sprints beside Joe toward the awakening carriage. Lyra says exactly: "Then we ride the dead line. Whatever is conducting this invasion is waiting at the last stop."

00:26-00:30 — One final Stage 1 robot lunges through the smoke. Joe knocks it back with a brass resonance ring while Lyra hooks the carriage door with her keytar and swings both heroes aboard. The train dives forward through a cyan-violet cosmic rail tunnel. Finish with their complete weapons and gear visible, ready for Stage 2, and distant Vinyl Drone silhouettes forming ahead.

Synchronised sound effects: boss collapse, speaker pressure wave, cooling metal, First Press vinyl shimmer, projected-note pulses without words, stairwell footsteps, old relay clicks, rail power surge, chain break, keytar chord, carriage-door slam, Kazoo pop, robot impact and cosmic-speed rail rush. Preserve spatial clarity and exact speech.

No visible text of any kind: no title, station label, map label, subtitle, caption, speech bubble, logo, HUD, credits or watermark. Make the musical map abstract and non-linguistic. Exact dialogue only. Static Baron remains defeated. Preserve both heroes' accumulated equipment. Do not reveal the Grand Conductor.

If native 30-second generation is unavailable: generate 00:00-00:15 with the discovery, Lyra's complete first line and Joe's complete line timed slightly earlier than the native-30 plan. Then extend 15 seconds from the dark Orbit Line reveal without repeating dialogue. Preserve the direction of the projected map, transition on-beat from Audio 1 into Audio 2, deliver Lyra's complete final line and end with both heroes aboard the descending train.
```

---

## 5. Ending — An Encore in Orbit

### Reference upload map

- `@Image 1` — `assets/generated/cutscenes/campaign-atlas.png` — authoritative
  Orbit Line and distant-threat composition.
- `@Image 2` — `assets/generated/campaign/character-portraits-atlas.png` — Joe
  and Lyra identity.
- `@Image 3` — `assets/generated/campaign/joe-action-sheet.png` — Joe movement.
- `@Image 4` — `assets/generated/campaign/lyra-action-sheet.png` — Lyra movement.
- `@Image 5` — `assets/generated/campaign/stage2-enemies-atlas.png` — Grand
  Orchestrator design in the bottom-right cell and Stage 2 enemy roster.
- `@Image 6` — `assets/generated/campaign/stage2-environment-atlas.png` — Orbit
  Line machinery and transit forms.
- `@Image 7` — `assets/generated/campaign/orbit-environment-expansion-atlas.png`
  — Orbit Line location language.
- `@Audio 1` — `assets/music/30_ending_teaser.ogg` — distant-orchestra ending
  cue.

### 15-second variation

```text
Create an exact 15-second, 16:9 ending-teaser cutscene for Groove Bound. Reference chain: @Image 1 ++ @Image 2 ++ @Image 3 ++ @Image 4 ++ @Image 5 ++ @Image 6 ++ @Image 7 ++ @Audio 1. Use Image 1 for the Orbit Line composition and cosmic signal; use Images 2, 3 and 4 to keep Joe and Lyra perfectly on-model; use Image 5 for the defeated Grand Orchestrator's exact local body design; and use Images 6 and 7 for the Orbit Line. Critical story distinction: the Grand Orchestrator lies defeated on the platform, while the speaking Grand Conductor is a separate, distant, unrevealed intelligence represented only by an enormous waveform silhouette beyond the stars. Do not merge them. Detailed cinematic 16-bit pixel art with crisp 8-bit pixel discipline, stable pixel clusters and spectacular but readable scale; never 3D, photoreal, vector, anime or painterly.

Music source and path: use Audio 1 from `assets/music/30_ending_teaser.ogg` for the full 00:00-00:15. Preserve the supplied 96 BPM instrumental teaser, duck under dialogue and sync the cosmic pulses to its beat.

00:00-00:04.2 — The Grand Orchestrator collapses in sparks, its giant speaker core dimming as Joe and Lyra stand exhausted but upright. The stars suddenly pulse like a colossal equaliser. A vast off-screen synthetic bass voice—the Grand Conductor—says exactly: "FIRST MOVEMENT: INCOMPLETE. ASSEMBLING THE ORCHESTRA."

00:04.2-00:09.5 — Broken machine parts lift weightlessly and arrange into distant instrument silhouettes around an immense waveform in space. Joe reloads his Kazoo Pistol, gives a wry half-smile and says exactly: "That was only one piece of it. Good. I was worried the night might end early."

00:09.5-00:15 — Lyra steps onto the ruined turntable core, strikes one defiant cyan-magenta keytar chord and sends a resonance beacon racing back toward the lights of Backbeat. She says exactly: "Let it assemble. Next time, we bring the whole city as our backing band." End on Joe and Lyra side by side, tiny against the stars but brightly outlined, as many city lights answer their pulse.

Synchronised sound effects: giant robot collapse, heavy speaker power-down, small electrical sparks, vacuum-like cosmic pulse, distant layered sub resonance for the Conductor, floating debris chimes, Kazoo reload click, keytar power chord and citywide response pulses. Keep the Conductor intelligible, ominous and distant rather than deafening.

No visible text: do not display the Conductor's words, titles, subtitles, captions, speech bubbles, logos, HUD, labels, credits or watermark. Exact dialogue only. Joe and Lyra lip-sync only their lines; the Grand Conductor remains off-screen. Do not show a complete Grand Conductor body or resurrect the Grand Orchestrator.
```

### 30-second variation

```text
Create an exact 30-second, 16:9 ending-teaser cutscene for Groove Bound. Reference chain: @Image 1 ++ @Image 2 ++ @Image 3 ++ @Image 4 ++ @Image 5 ++ @Image 6 ++ @Image 7 ++ @Audio 1. Use Image 1 as the authoritative visual language; Images 2, 3 and 4 as strict Joe and Lyra identity and movement references; Image 5 for the Grand Orchestrator; and Images 6 and 7 for the Orbit Line. Critical canon distinction: the defeated local boss is the Grand Orchestrator. The speaker is the separate and distant Grand Conductor, an unknown intelligence represented only through star-scale waveform geometry, shadowed instrument silhouettes and voice. Never reveal its complete form or combine it with the fallen boss. Render detailed cinematic 16-bit pixel art with strict 8-bit pixel discipline, stable pixel-grid scale, dark outlines, stepped cosmic light and measured high-impact animation. Never become 3D CGI, live action, vector, anime or painterly.

Music source and path: use Audio 1 from `assets/music/30_ending_teaser.ogg` continuously from 00:00-00:30. Preserve the exact supplied 96 BPM instrumental cue, loop only at its authored 32-beat boundary around 00:20, duck beneath dialogue and align large cosmic pulses to the beat.

00:00-00:07 — Finish the battle in motion: Joe's final brass resonance ring and Lyra's keytar chord strike the Grand Orchestrator's speaker core together. The giant machine freezes for one silent anticipation frame, then collapses across the Orbit Line platform in controlled pieces. Joe and Lyra land, breathing hard, surrounded by fading cyan and magenta sparks.

00:07-00:14 — The apparent quiet breaks when every star blinks out, then returns as one enormous equaliser wave. The dead Orchestrator remains clearly visible in foreground. Beyond the station, shadowed instrument forms begin taking positions around an unrevealed intelligence. The off-screen Grand Conductor says exactly: "FIRST MOVEMENT: INCOMPLETE. ASSEMBLING THE ORCHESTRA."

00:14-00:21 — The camera slowly pushes past floating debris toward Joe. He studies one small surviving machine fragment as it projects many distant signals, reloads his Kazoo Pistol and gives a wry half-smile. Joe says exactly: "That was only one piece of it. Good. I was worried the night might end early."

00:21-00:28 — Lyra climbs onto the broken turntable core and looks across space toward Backbeat. She plants her feet, raises the keytar and says exactly: "Let it assemble. Next time, we bring the whole city as our backing band." On "whole city," she strikes a huge cyan-magenta chord that travels along the dead rail and becomes a beacon above Backbeat.

00:28-00:30 — Thousands of city lights pulse back in rhythm. Cut between the signal crossing space and the two heroes standing side by side. End on a strong wide silhouette with the distant orchestra still assembling beyond them, unresolved and ready for the next campaign chapter.

Synchronised sound effects: final resonance impact, giant mechanical collapse, debris and small sparks, sudden near-silence, star-scale sub pulse, layered distant synthetic voice, floating metallic chimes, Kazoo reload click, keytar power chord, rail-energy rush and city response. Keep dialogue clean, centred and emotionally distinct.

No visible words of any kind: no title, subtitle, captions, speech bubbles, projected message, logo, HUD, labels, credits or watermark. Exact dialogue only. Grand Conductor remains off-screen and unrevealed. Grand Orchestrator remains destroyed. No resurrection, extra dialogue, singing, chanting or gore.

If native 30-second generation is unavailable: generate 00:00-00:15 through the Grand Conductor's complete exact line, then extend 15 seconds from the first floating machine fragment. Preserve the fallen Orchestrator, character models, spatial direction and Audio 1 continuity; deliver Joe's and Lyra's complete exact lines and finish on Backbeat answering the beacon.
```

## Acceptance checklist for every returned video

- Exact duration: 15.0 or 30.0 seconds.
- 16:9 landscape, full bleed, no letterbox or embedded game UI.
- Every canonical line is present once, verbatim, assigned to the correct voice
  and intelligibly timed.
- Joe and Lyra remain recognisable and on-model in every shot.
- Pixel grid, palette and rendering stay stable during motion and transitions.
- Correct project music cue is present and no replacement music is invented.
- Foley and impacts are synchronised; music ducks beneath speech.
- No on-screen text, captions, subtitles, logos, watermarks or readable signs.
- Ending preserves the Grand Orchestrator / Grand Conductor distinction.
- Final frame supports a clean transition back into gameplay or results.
