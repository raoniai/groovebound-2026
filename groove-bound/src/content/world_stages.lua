-- Playable World Tour stages. A world owns an ordered stage array so the
-- combat build, health and World mechanic record can carry across locations.

local pocket_pads = {
  { x = 2500, y = 1600 },
  { x = 2050, y = 1280 },
  { x = 2950, y = 1280 },
  { x = 2050, y = 1920 },
  { x = 2950, y = 1920 },
}

local afterparty_pads = {
  { x = 2800, y = 1800 },
  { x = 2200, y = 1320 },
  { x = 3400, y = 1320 },
  { x = 2200, y = 2280 },
  { x = 3400, y = 2280 },
}

local function mechanic(pads, cycle_seconds, radius)
  return {
    id = "funk_hold_the_pocket",
    cycle_seconds = cycle_seconds,
    active_window = 0.28,
    boost_seconds = 2.8,
    boost_multiplier = 1.55,
    radius = radius,
    pads = pads,
  }
end

local function themed_stage(id, world_id, name, subtitle, final_boss, wave_module,
    mechanic_id, stage_index)
  local width, height = 5400 + stage_index * 200, 3400 + stage_index * 160
  local pads = {
    { x=width/2, y=height/2 }, { x=width*.36, y=height*.34 },
    { x=width*.64, y=height*.34 }, { x=width*.36, y=height*.66 },
    { x=width*.64, y=height*.66 },
  }
  local obs, deco = {}, {}
  local positions = {
    { .12,.16 },{ .30,.12 },{ .50,.14 },{ .70,.12 },{ .88,.16 },
    { .12,.82 },{ .30,.86 },{ .50,.84 },{ .70,.86 },{ .88,.82 },
  }
  for i,p in ipairs(positions) do obs[#obs+1] = { x=width*p[1], y=height*p[2],
    w=230+(i%3)*18, h=210+(i%2)*18, icon={col=(i-1)%4+1,row=1} } end
  local dpos={{.20,.34},{.80,.34},{.18,.64},{.82,.64},{.32,.50},{.68,.50},{.50,.26},{.50,.74}}
  for i,p in ipairs(dpos) do deco[#deco+1] = { x=width*p[1], y=height*p[2],
    size=145+(i%3)*14, icon={col=(i-1)%4+1,row=2},
    blocks_base=(i==1 or i==2), hitbox_w=78, hitbox_h=38, hitbox_offset_y=58 } end
  return { id=id, world_id=world_id, name=name, subtitle=subtitle,
    width=width, height=height, base_duration=240, wave_base_duration=600,
    waves=require(wave_module), final_boss=final_boss,
    floor_style=world_id, environment_atlas=world_id,
    floor_tint=world_id=="soul" and { .82,.68,.88,1 } or { .70,.78,.96,1 },
    veil_color=world_id=="soul" and { .08,.012,.065,.26 } or { .012,.025,.075,.24 },
    grid_color=world_id=="soul" and { 1,.55,.42,.35 } or { .35,.92,1,.34 },
    mechanic={ id=mechanic_id, cycle_seconds=world_id=="soul" and 4.6 or 3.0,
      active_window=world_id=="soul" and .72 or .34,
      charge_seconds=world_id=="soul" and 1.15 or .38,
      boost_seconds=world_id=="soul" and 1.4 or 2.4,
      boost_multiplier=world_id=="soul" and 1.08 or 1.42,
      heal_fraction=world_id=="soul" and .07 or 0,
      radius=world_id=="soul" and 128 or 118, pads=pads },
    obstacles=obs, decorations=deco }
end

return {
  funk = {
    {
      id = "world_funk_pocket_district",
      world_id = "funk",
      name = "THE POCKET DISTRICT",
      subtitle = "Hold the pocket. Catch the gold downbeat.",
      width = 5000,
      height = 3200,
      base_duration = 240,
      wave_base_duration = 600,
      waves = require("src.content.world_tour_waves.funk"),
      final_boss = "boogie_tank",
      floor_style = "funk",
      floor_tint = { 0.86, 0.78, 0.98, 1 },
      veil_color = { 0.025, 0.008, 0.055, 0.24 },
      grid_color = { 1.0, 0.68, 0.18, 0.40 },
      environment_atlas = "funk",
      mechanic = mechanic(pocket_pads, 2.2, 112),
      obstacles = {
        { x = 620, y = 450, w = 260, h = 225, icon = { col = 1, row = 1 } },
        { x = 1410, y = 390, w = 230, h = 220, icon = { col = 2, row = 1 } },
        { x = 2380, y = 390, w = 260, h = 230, icon = { col = 3, row = 1 } },
        { x = 3470, y = 430, w = 230, h = 220, icon = { col = 2, row = 1 } },
        { x = 4140, y = 520, w = 250, h = 215, icon = { col = 4, row = 1 } },
        { x = 600, y = 2420, w = 250, h = 215, icon = { col = 4, row = 1 } },
        { x = 1510, y = 2520, w = 270, h = 225, icon = { col = 1, row = 1 } },
        { x = 3260, y = 2490, w = 260, h = 230, icon = { col = 3, row = 1 } },
        { x = 4150, y = 2380, w = 230, h = 220, icon = { col = 2, row = 1 } },
      },
      decorations = {
        { x = 1080, y = 1020, size = 190, icon = { col = 1, row = 2 },
          blocks_base = true, hitbox_w = 84, hitbox_h = 44, hitbox_offset_y = 64 },
        { x = 1860, y = 890, size = 145, icon = { col = 2, row = 2 } },
        { x = 3140, y = 890, size = 150, icon = { col = 2, row = 2 } },
        { x = 3930, y = 1040, size = 180, icon = { col = 1, row = 2 },
          blocks_base = true, hitbox_w = 80, hitbox_h = 42, hitbox_offset_y = 61 },
        { x = 1180, y = 1980, size = 145, icon = { col = 3, row = 2 } },
        { x = 1760, y = 2220, size = 150, icon = { col = 4, row = 2 } },
        { x = 3240, y = 2220, size = 150, icon = { col = 4, row = 2 } },
        { x = 3850, y = 1960, size = 145, icon = { col = 3, row = 2 } },
      },
    },
    {
      id = "world_funk_golden_afterparty",
      world_id = "funk",
      name = "THE GOLDEN AFTERPARTY",
      subtitle = "Push deeper. Board the Mothership on the one.",
      width = 5600,
      height = 3600,
      base_duration = 240,
      wave_base_duration = 600,
      waves = require("src.content.world_tour_waves.funk_stage2"),
      final_boss = "mothership_of_funk",
      floor_style = "funk",
      floor_tint = { 0.72, 0.68, 0.92, 1 },
      veil_color = { 0.055, 0.006, 0.075, 0.30 },
      grid_color = { 0.30, 0.90, 1.0, 0.34 },
      environment_atlas = "funk",
      mechanic = mechanic(afterparty_pads, 1.95, 118),
      obstacles = {
        { x = 560, y = 470, w = 285, h = 240, icon = { col = 1, row = 1 } },
        { x = 1470, y = 510, w = 255, h = 235, icon = { col = 3, row = 1 } },
        { x = 2610, y = 390, w = 240, h = 225, icon = { col = 2, row = 1 } },
        { x = 3720, y = 510, w = 255, h = 235, icon = { col = 3, row = 1 } },
        { x = 4740, y = 470, w = 285, h = 240, icon = { col = 1, row = 1 } },
        { x = 720, y = 1660, w = 250, h = 220, icon = { col = 4, row = 1 } },
        { x = 4620, y = 1660, w = 250, h = 220, icon = { col = 4, row = 1 } },
        { x = 560, y = 2890, w = 260, h = 230, icon = { col = 2, row = 1 } },
        { x = 1570, y = 2910, w = 285, h = 240, icon = { col = 1, row = 1 } },
        { x = 2700, y = 2970, w = 260, h = 230, icon = { col = 3, row = 1 } },
        { x = 3800, y = 2910, w = 285, h = 240, icon = { col = 1, row = 1 } },
        { x = 4780, y = 2890, w = 260, h = 230, icon = { col = 2, row = 1 } },
      },
      decorations = {
        { x = 1120, y = 1040, size = 195, icon = { col = 1, row = 2 },
          blocks_base = true, hitbox_w = 86, hitbox_h = 46, hitbox_offset_y = 66 },
        { x = 2150, y = 950, size = 150, icon = { col = 2, row = 2 } },
        { x = 3450, y = 950, size = 150, icon = { col = 2, row = 2 } },
        { x = 4480, y = 1040, size = 195, icon = { col = 1, row = 2 },
          blocks_base = true, hitbox_w = 86, hitbox_h = 46, hitbox_offset_y = 66 },
        { x = 1320, y = 2250, size = 155, icon = { col = 3, row = 2 } },
        { x = 2050, y = 2550, size = 155, icon = { col = 4, row = 2 } },
        { x = 3550, y = 2550, size = 155, icon = { col = 4, row = 2 } },
        { x = 4280, y = 2250, size = 155, icon = { col = 3, row = 2 } },
      },
    },
  },
  soul = {
    themed_stage("world_soul_velvet_nave", "soul", "THE VELVET NAVE",
      "Charge a resonance pool. Spend the harmony to recover.",
      "organ_colossus", "src.content.world_tour_waves.soul",
      "soul_resonance_reserve", 1),
    themed_stage("world_soul_sanctuary_chorus", "soul", "THE SANCTUARY CHORUS",
      "Answer the Titan's call and keep the sanctuary singing.",
      "velvet_titan", "src.content.world_tour_waves.soul_stage2",
      "soul_resonance_reserve", 2),
  },
  disco = {
    themed_stage("world_disco_mirrorball_concourse", "disco", "MIRRORBALL CONCOURSE",
      "Follow the moving spotlight for a prism-speed surge.",
      "laser_conductor", "src.content.world_tour_waves.disco",
      "disco_spotlight_flow", 1),
    themed_stage("world_disco_prism_platform", "disco", "THE PRISM PLATFORM",
      "Ride the bonus lane and dethrone the Prism Monarch.",
      "prism_monarch", "src.content.world_tour_waves.disco_stage2",
      "disco_spotlight_flow", 2),
  },
}
