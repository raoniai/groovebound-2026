-- One-shot animated combat feedback. Callers emit semantic effects; frame
-- choice, lifetime, and sprite-row mapping stay local to this module.

local class = require("src.core.class")

local VFXSystem = class()

local rows = {
  hit = 1,
  damage = 2,
  explosion = 3,
  player_hurt = 4,
}

function VFXSystem:init(assets)
  self.assets = assets
  self.effects = {}
end

function VFXSystem:spawn(kind, x, y, opts)
  opts = opts or {}
  self.effects[#self.effects + 1] = {
    kind = kind,
    x = x,
    y = y,
    age = 0,
    duration = opts.duration or (kind == "explosion" and 0.48 or 0.24),
    scale = opts.scale or 0.24,
    rotation = opts.rotation or 0,
    color = opts.color or { 1, 1, 1, 1 },
    enemy_id = opts.enemy_id,
    enemy_size = opts.enemy_size,
    flip_x = opts.flip_x,
  }
end

function VFXSystem:update(dt)
  for index = #self.effects, 1, -1 do
    local effect = self.effects[index]
    effect.age = effect.age + dt
    if effect.age >= effect.duration then
      table.remove(self.effects, index)
    end
  end
end

function VFXSystem:draw()
  if not self.assets then return end
  for _, effect in ipairs(self.effects) do
    local progress = math.min(0.999, effect.age / effect.duration)
    local frame = math.floor(progress * 4) + 1
    local alpha = math.min(1, (1 - progress) * 1.7)
    local color = {
      effect.color[1], effect.color[2], effect.color[3],
      (effect.color[4] or 1) * alpha,
    }
    if effect.kind == "enemy_death" and self.assets.draw_enemy_state then
      self.assets:draw_enemy_state(
        effect.enemy_id, "death", frame, effect.x, effect.y,
        effect.enemy_size or 82,
        { flip_x = effect.flip_x, color = color })
    elseif self.assets.combat_fx then
      self.assets.combat_fx:draw(
        frame, rows[effect.kind] or 1, effect.x, effect.y,
        {
          scale = effect.scale,
          rotation = effect.rotation,
          color = color,
        })
    end
  end
end

function VFXSystem:clear()
  self.effects = {}
end

return VFXSystem
