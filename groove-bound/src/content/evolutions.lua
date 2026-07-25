-- Weapon evolution recipes.
--
-- Evolution logic reads only stable IDs. Display names may change safely.
-- The trigger is explicit so a normal level-up cannot silently perform a
-- boss-chest evolution.

return {
  kazoo_studio = {
    id = "kazoo_studio",
    name = "Kazoo Studio Evolution",
    base_weapon = "kazoo_pistol",
    result_weapon = "brass_barrage",
    branch = "studio",
    required_weapon_level = 10,
    required_passives = {
      { id = "breath_control", min_level = 1 },
    },
    trigger = "resolve_reward",
    consume_passives = false,
  },

  kazoo_live = {
    id = "kazoo_live",
    name = "Kazoo Live Evolution",
    base_weapon = "kazoo_pistol",
    result_weapon = "improvised_solo",
    branch = "live",
    required_weapon_level = 10,
    required_passives = {
      { id = "breath_control", min_level = 1 },
    },
    trigger = "resolve_reward",
    consume_passives = false,
  },
}
