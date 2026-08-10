-- Loads and validates the full content bundle. Required once at boot;
-- any schema violation is a loud boot error, never a silent fallback.

local Validate = require("src.content.validate")

local content = {
  weapons    = require("src.content.weapons"),
  enemies    = require("src.content.enemies"),
  passives   = require("src.content.passives"),
  evolutions = require("src.content.evolutions"),
  characters = require("src.content.characters"),
  waves      = require("src.content.waves"),
  stages     = require("src.content.stages"),
  narrative  = require("src.content.narrative"),
  world_tour = require("src.content.world_tour"),
  world_tour_waves = {
    funk = require("src.content.world_tour_waves.funk"),
    soul = require("src.content.world_tour_waves.soul"),
  },
  meta_perks = require("src.content.meta_perks"),
  meta_rewards = require("src.content.meta_rewards"),
  grade_profiles = require("src.content.grade_profiles"),
  remix_tiers = require("src.content.remix_tiers"),
}

return Validate.assert_valid(content)
