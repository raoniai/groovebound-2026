# Interface and accessibility contracts

## Current baseline

- Reference window: 1280 by 720.
- Minimum window: 800 by 600.
- Inputs: keyboard, mouse, and gamepad.
- Persistent options: volume, feedback effects, fullscreen, aim assistance, deadzone, and keyboard bindings.
- Debug/Admin routes: Tab and F1, with menu access where implemented.

## Screen checks

- Focus is visible and never trapped.
- Confirm and back work once per physical action.
- Pause blocks simulation and resumes the correct state.
- Text and controls remain inside the safe area.
- Essential status is not encoded by color alone.
- Long labels and rebinding conflicts remain legible.
- Animations respect available effect controls and future reduced-motion policy.

## Controller boundary

Treat hot-plug awareness, device-specific glyphs, remapping, wired/wireless parity, and advanced DualSense features as separate acceptance items. Read `groove-bound/docs/PLAYSTATION_CONTROLLER_PLAN.md` for the planned matrix.
