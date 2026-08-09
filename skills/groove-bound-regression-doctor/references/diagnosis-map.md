# Diagnosis map

| Symptom | Start with | Then inspect |
|---|---|---|
| Different outcome for same seed | RNG and run context | progression, spawn, combat streams |
| Enemy crosses or sticks on obstacles | arena movement resolution | enemy brain and navigation intent |
| Duplicate or missing transition | state machine and RunScreen | queued rewards and cutscenes |
| Double input | InputEventGate | screen keyboard/gamepad handlers |
| Source works, package fails | package manifest | excluded asset or filename case |
| Video or audio issue | media path and codec | router, screen lifecycle, fallback |
| Save resets | schema envelope and backend | identity, defaults, migration path |
| Visual request appears incomplete | exact rendering owner | asset mapping and manual QA |

Treat a headless SDL/OpenGL failure as an environment constraint until the same build fails in a display-capable context.
