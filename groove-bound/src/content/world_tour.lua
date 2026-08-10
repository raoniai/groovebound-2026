-- Canonical World Tour catalog. Funk and Soul have authored wave sets; the
-- remaining worlds stay catalog-visible but are not routed into gameplay yet.

local worlds = {
  { "funk", 1, "core", "The Pocket District", "Funk", "funk_v1", "funk_hold_the_pocket", "breakbeat_bruiser", "soul" },
  { "soul", 2, "core", "Velvet Chapel", "Soul", "soul_v1", "soul_resonance_reserve", "Velvet Titan", "disco" },
  { "disco", 3, "core", "Mirrorball Metro", "Disco", "disco_v1", "disco_spotlight_flow", "Prism Monarch", "house" },
  { "house", 4, "core", "Warehouse 909", "House", "house_v1", "house_floor_cycles", "Kickdrum Constructor", "electro" },
  { "electro", 5, "core", "Neon Circuit", "Electro", "electro_v1", "electro_node_chains", "Voltage Vandal", "techno" },
  { "techno", 6, "core", "The Iron Loop", "Techno", "techno_v1", "techno_loop_memory", "Loop Architect", nil },
  { "cosmic_boogie", 7, "secret", "Orbital Dance Deck", "Cosmic Boogie",
    "cosmic_boogie_v1", "cosmic_orbit_pocket", "Celestial Selector", nil },
  { "soulful_garage", 8, "secret", "Midnight Garage", "Soulful Garage",
    "soulful_garage_v1", "garage_resonance_gates", "Night Shift Conductor", nil },
  { "future_funk", 9, "secret", "Tomorrow Mall", "Future Funk",
    "future_funk_v1", "future_sampled_loops", "The Recompiler", nil },
}

local catalog = {}
for _, row in ipairs(worlds) do
  local id, order, kind, name, genre, grade_profile, mastery_id, boss, next_world = unpack(row)
  catalog[id] = {
    id = id, order = order, type = kind, name = name, genre = genre,
    duration_seconds = 600, stage_id = "world_" .. id,
    wave_set = id, enemy_family = id .. "_ensemble", final_boss = boss,
    grade_profile = grade_profile, mastery_id = mastery_id,
    music_route = "world_" .. id, environment_atlas = "world_" .. id,
    floor_atlas = "world_" .. id .. "_floor", first_clear_unlock = next_world,
    implementation_status = id == "funk" and "playable"
      or id == "soul" and "catalog_ready" or "planned",
    rewards = {
      C = "world_" .. id .. "_grade_c", B = "world_" .. id .. "_grade_b",
      A = "world_" .. id .. "_grade_a", S = "world_" .. id .. "_grade_s",
    },
  }
end

catalog.cosmic_boogie.parents = { "funk", "disco" }
catalog.soulful_garage.parents = { "soul", "house" }
catalog.future_funk.parents = { "electro", "techno" }

return catalog
