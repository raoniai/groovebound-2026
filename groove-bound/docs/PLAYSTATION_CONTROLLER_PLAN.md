# PlayStation Controller Support Plan

## Current baseline

Groove Bound already uses LÖVE's standardized gamepad interface, so DualSense
and DualShock controllers recognized by SDL can currently provide:

- left-stick movement and right-stick aim;
- Cross confirm, Circle cancel, Options pause;
- D-pad and shoulder navigation in menus and Admin;
- configurable dead zone and optional vibration.

Keyboard and mouse remain independent and must continue working when a
controller connects or disconnects during play.

## Delivery stages

### 1. Connection awareness and prompts

- Track `love.joystickadded` and `love.joystickremoved` hot-plug events.
- Record the active device by stable joystick ID instead of assuming the first
  item returned by LÖVE.
- Switch prompts between keyboard/mouse and PlayStation glyphs based on the
  most recently used device.
- Show a brief, non-blocking "Controller connected" or "Controller removed"
  notice.

### 2. PlayStation mapping and compatibility

Use LÖVE's standard names internally while displaying PlayStation labels:

| Game action | LÖVE input | PlayStation label |
|---|---|---|
| Confirm | `a` | Cross |
| Cancel | `b` | Circle |
| Alternate action | `x` | Square |
| Reset / secondary | `y` | Triangle |
| Pause | `start` | Options |
| Section navigation | shoulders | L1 / R1 |

Verify DualSense and DualShock 4 over both USB and Bluetooth on macOS and
Windows. Confirm axes, D-pad, pause, menu focus, disconnect/reconnect, and
vibration. Platform testing must record controller name, OS, connection type,
and result.

### 3. Accessibility and remapping

- Add controller remapping without changing keyboard bindings.
- Allow independent movement and aim dead zones.
- Provide vibration strength and an explicit off setting.
- Keep every menu operable without pointer input and preserve visible focus.

### 4. Advanced DualSense features

Adaptive triggers, light bar, speaker audio, and HD-haptics-style effects are
out of scope until a cross-platform library can be isolated behind the input
layer. Standard vibration remains the portable baseline.

## Acceptance checks

Controller support is ready for release only when:

1. plugging in, unplugging, and reconnecting never interrupts a run;
2. every campaign, cutscene, level-up, pause, options, results, Arsenal, and
   Admin screen is navigable with a PlayStation controller;
3. prompts accurately follow the last-used device;
4. no controller path changes keyboard/mouse behavior;
5. USB and Bluetooth test passes are recorded for DualSense and DualShock 4;
6. automated input-mapping tests, a full controller playthrough, and package
   boot verification all pass.
