# Groove Bound CTA and menu sprite direction

This is the default art and implementation contract for future buttons, menu
icons, settings controls, and final-stat symbols.

## Visual hierarchy

- CTA and menu sprites are interface support, never miniature gameplay art.
- Use one cyan hue family per sprite. Create depth with luminance and saturation
  changes only; reserve near-black navy for negative space.
- Prefer one strong, self-explanatory silhouette over props, scenes, particles,
  glow clouds, or decorative hardware.
- Keep stroke weight and apparent icon mass consistent across an atlas.
- Essential state is communicated by outline, scale, label, and focus treatment,
  not by colour alone.

## Runtime construction

- Build CTA backgrounds as nine-slice sprites so corners remain crisp at every
  supported button size.
- Keep labels live in Lua; never bake button text into a sprite.
- Keep icons in exact equal-cell RGBA atlases with at least 16 percent safe
  padding and no cross-cell pixels.
- The current stable mappings are `menu-stat-icons-v1.png` (menu actions and
  result statistics) and `settings-icons-v1.png` (options and controls).
- Preserve raw generated source candidates separately and exclude them from
  packages. Runtime files live under `assets/generated/campaign/ui/`.

## Accessibility acceptance

- Verify silhouettes at 28, 32, 42, and 48 pixels.
- Verify focus without colour, using the bright outline and text treatment.
- Keep pointer targets at least 24 pixels and primary actions at least 40 pixels
  high on the 1280 by 720 reference canvas.
- Check 800 by 600, 1280 by 720, widescreen, keyboard, mouse, and gamepad.
- Sliders require a visible track, filled range, thumb, value, and explicit
  decrease/increase affordances.

Do not add a new CTA or menu atlas that returns to multicolour loot-style art
without an explicit art-direction decision.
