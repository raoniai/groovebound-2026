---
name: groove-bound-interface-accessibility
description: Design, implement, or verify Groove Bound screens, HUD, menus, controls, controller behavior, options, input rebinding, focus flow, readability, responsive layout, and accessibility. Use for keyboard, mouse, gamepad, PlayStation controller, vibration, flashing, screen shake, aim assistance, deadzone, or reduced-motion work.
---

# Groove Bound interface and accessibility

Keep screen hierarchy, state transitions, and input behavior coherent across supported devices and resolutions.

## Workflow

1. Read `LATEST_VERSION_HANDOVER.md`, inspect the owning screen and existing input tests, and read [references/interface-contracts.md](references/interface-contracts.md).
2. Define the task, focus order, confirm/back behavior, pause behavior, and device parity before changing layout.
3. Preserve `InputEventGate`, state-stack ownership, options persistence, and conflict-checked rebinding.
4. Use the existing design system and authentic project assets. Do not replace established identity with generic UI.
5. Add layout or input tests for deterministic geometry and transitions.
6. Check keyboard, mouse, generic gamepad, minimum window, reference window, widescreen, and high-DPI behavior as applicable.
7. Verify text contrast, effect toggles, motion intensity, flash, shake, vibration, aim support, deadzone, and readable controller hints.
8. Perform manual device and visual QA. Mark unavailable hardware or display checks unverified.
9. Route new art, audio, or video through `$groove-bound-media-pipeline`.

## Do not infer

- A generic gamepad test does not prove PlayStation glyph or hot-plug support.
- A geometry unit test does not prove readability.
- A desktop screenshot does not prove minimum-window or high-DPI behavior.
