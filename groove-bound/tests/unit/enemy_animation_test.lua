local H = require("tests.helpers")
local Enemy = require("src.game.entities.enemy")
local EnemyAnimation = require("src.render.enemy_animation")
local enemies = require("src.content.enemies")

local T = {}

T["every enemy definition resolves to an in-bounds animation frame set"] = function()
  local count = 0
  for id, definition in pairs(enemies) do
    count = count + 1
    local frame_count = EnemyAnimation.frame_count(definition.sprite)
    H.is_true(frame_count == 3 or frame_count == 4, id)
    local atlas_id = EnemyAnimation.atlas_id(definition.sprite)
    H.is_true(atlas_id ~= nil, id)
    local rows = atlas_id == "jazz" and 8 or 6
    for frame = 1, frame_count do
      local row, col = EnemyAnimation.cell(definition.sprite, frame)
      H.is_true(row >= 1 and row <= rows, id .. " row")
      H.is_true(col >= 1 and col <= 4, id .. " col")
    end
  end
  H.eq(count, 49)
end

T["Breakbeat Bruiser explicitly shares the Turntable Sentinel animation"] = function()
  for frame = 1, 3 do
    local break_row, break_col = EnemyAnimation.cell(
      enemies.breakbeat_bruiser.sprite, frame)
    local sentinel_row, sentinel_col = EnemyAnimation.cell(
      enemies.turntable_sentinel.sprite, frame)
    H.eq(break_row, sentinel_row)
    H.eq(break_col, sentinel_col)
  end
end

T["visual phases are deterministic and do not require a gameplay RNG"] = function()
  local first = EnemyAnimation.phase("monotone", 120, 80)
  local repeat_value = EnemyAnimation.phase("monotone", 120, 80)
  local second = EnemyAnimation.phase("monotone", 121, 80)
  H.eq(first, repeat_value)
  H.is_true(first >= 0 and first < 1)
  H.is_true(second >= 0 and second < 1)
  H.is_true(first ~= second)
end

T["static enemy animation advances without changing simulation state"] = function()
  local drawn = {}
  local assets = {
    draw_enemy_variant = function(_, _, _, _, _, opts)
      drawn[#drawn + 1] = opts.frame
    end,
  }
  local enemy = Enemy()
  enemy:reset({
    definition = {
      id = "static_test", hp = 40, speed = 0, size = 12, damage = 5,
      brain = "static", sprite = { col = 1, row = 1 }, sprite_size = 70,
    },
    assets = assets,
    x = 30,
    y = 40,
  })
  local start_x, start_y, start_hp = enemy.x, enemy.y, enemy.hp
  enemy:draw()
  enemy:update(0.21, { x = 80, y = 40 }, 1, {})
  enemy:draw()
  H.is_true(drawn[1] ~= drawn[2])
  H.eq(enemy.x, start_x)
  H.eq(enemy.y, start_y)
  H.eq(enemy.hp, start_hp)
end

T["animated enemy rendering preserves left-facing horizontal flip"] = function()
  local flip_x
  local assets = {
    draw_enemy_variant = function(_, _, _, _, _, opts)
      flip_x = opts.flip_x
    end,
  }
  local enemy = Enemy()
  enemy:reset({
    definition = {
      id = "walker", hp = 40, speed = 20, size = 12, damage = 5,
      brain = "chase", sprite = { col = 1, row = 1 }, sprite_size = 70,
    },
    assets = assets,
    x = 50,
    y = 50,
  })
  enemy:update(0.1, { x = 10, y = 50 }, 1, {
    clamp = function(_, x, y) return x, y end,
  })
  enemy:draw()
  H.is_true(flip_x)
end

return T
