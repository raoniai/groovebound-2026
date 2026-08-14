local H = require("tests.helpers")
local Validate = require("src.content.validate")

local T = {}

T["World Tour catalog has nine stable worlds and four playable routes"] = function()
  local content = require("src.content.init")
  local count = 0
  for _ in pairs(content.world_tour) do count = count + 1 end
  H.eq(count, 9)
  H.eq(content.world_tour.funk.order, 1)
  H.eq(content.world_tour.funk.first_clear_unlock, "soul")
  H.eq(content.world_tour.soul.order, 2)
  H.eq(content.world_tour.funk.implementation_status, "playable")
  H.eq(content.world_tour.soul.implementation_status, "playable")
  H.eq(content.world_tour.disco.implementation_status, "playable")
  H.eq(content.world_tour.disco.first_clear_unlock, "jazz")
  H.eq(content.world_tour.jazz.order, 4)
  H.eq(content.world_tour.jazz.implementation_status, "playable")
  H.eq(content.world_tour.jazz.first_clear_unlock, "house")
  H.is_true(#content.world_tour_waves.funk >= 5)
  H.is_true(#content.world_tour_waves.soul >= 5)
  H.is_true(#content.world_tour_waves.disco >= 5)
  H.is_true(#content.world_tour_waves.jazz >= 5)
  H.eq(#content.world_stages.funk, 2)
  H.eq(content.world_stages.funk[1].world_id, "funk")
  H.eq(content.world_stages.funk[1].final_boss, "boogie_tank")
  H.eq(content.world_stages.funk[2].id,
    "world_funk_golden_afterparty")
  H.eq(content.world_stages.funk[2].final_boss,
    "mothership_of_funk")
  H.eq(#content.world_stages.funk[1].mechanic.pads, 5)
  H.eq(#content.world_stages.funk[2].mechanic.pads, 5)
  H.eq(content.enemies.mothership_of_funk.boss_type, "final")
  H.eq(content.enemies.mothership_of_funk.sprite.atlas, "funk")
  H.eq(#content.world_stages.soul, 2)
  H.eq(#content.world_stages.disco, 2)
  H.eq(#content.world_stages.jazz, 2)
  H.eq(content.world_stages.soul[2].final_boss, "velvet_titan")
  H.eq(content.world_stages.disco[2].final_boss, "prism_monarch")
  H.eq(content.world_stages.jazz[1].final_boss, "brass_regent")
  H.eq(content.world_stages.jazz[2].final_boss, "midnight_maestro")
end

T["Jazz world owns a complete visual roster and escalating second stage"] = function()
  local content = require("src.content.init")
  local jazz_enemy_count = 0
  for _, enemy in pairs(content.enemies) do
    if enemy.sprite and enemy.sprite.atlas == "jazz" then
      jazz_enemy_count = jazz_enemy_count + 1
    end
  end
  H.eq(jazz_enemy_count, 8)
  local first = content.world_stages.jazz[1]
  local second = content.world_stages.jazz[2]
  H.eq(first.floor_style, "jazz")
  H.eq(second.environment_atlas, "jazz")
  H.eq(first.mechanic.id, "jazz_improvisation")
  H.is_true(second.width > first.width)
  H.is_true(second.mechanic.cycle_seconds < first.mechanic.cycle_seconds)
  H.is_true(#second.waves[#second.waves].enemies >= 4)
end

T["Funk world has an authored visual roster and escalating second stage"] = function()
  local content = require("src.content.init")
  local funk_enemy_count = 0
  for _, enemy in pairs(content.enemies) do
    if enemy.sprite and enemy.sprite.atlas == "funk" then
      funk_enemy_count = funk_enemy_count + 1
    end
  end
  H.eq(funk_enemy_count, 8)
  local first = content.world_stages.funk[1]
  local second = content.world_stages.funk[2]
  H.eq(first.floor_style, "funk")
  H.eq(second.environment_atlas, "funk")
  H.is_true(second.width > first.width)
  H.is_true(second.mechanic.cycle_seconds < first.mechanic.cycle_seconds)
  H.is_true(#second.waves[#second.waves].enemies >= 4)
end

T["global meta catalog has nineteen perks and valid grade weights"] = function()
  local content = require("src.content.init")
  local count = 0
  for _ in pairs(content.meta_perks) do count = count + 1 end
  H.eq(count, 19)
  H.eq(content.meta_perks.open_ears.source.type, "prologue_clear")
  H.eq(content.meta_perks.pocket_drive.source.world_id, "funk")
  for _, profile in pairs(content.grade_profiles.profiles) do
    H.eq(profile.groove + profile.impact + profile.control
      + profile.craft + profile.world_mastery, 100)
  end
end

T["full content validation accepts the World Tour catalog"] = function()
  local content = require("src.content.init")
  H.eq(#Validate.check(content), 0)
end

T["every unevolved weapon has exactly one authored evolution"] = function()
  local content = require("src.content.init")
  local recipes_by_weapon = {}
  for _, recipe in pairs(content.evolutions) do
    recipes_by_weapon[recipe.base_weapon] =
      (recipes_by_weapon[recipe.base_weapon] or 0) + 1
    H.is_true(content.weapons[recipe.result_weapon].evolved == true)
  end
  for id, weapon in pairs(content.weapons) do
    if not weapon.evolved then
      H.eq(recipes_by_weapon[id], 1, id)
    end
  end
end

T["core worlds grant a gradual fresh-entry starter loadout"] = function()
  local Content = require("src.content.init")
  local expected = {
    funk = { 0, 0 }, soul = { 1, 0 }, disco = { 1, 1 },
    jazz = { 1, 1 }, house = { 2, 1 }, techno = { 2, 2 },
  }
  for id, counts in pairs(expected) do
    local loadout = Content.world_tour[id].starter_loadout
    H.eq(loadout.weapons, counts[1])
    H.eq(loadout.passives, counts[2])
  end
end

return T
