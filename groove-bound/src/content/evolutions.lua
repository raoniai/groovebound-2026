-- One weapon + one support fusion recipes. The base weapon must reach rank
-- ten. Selecting the evolution consumes the paired support and replaces the
-- base weapon in its exact active slot, freeing the support slot immediately.

local function fusion(id, name, base_weapon, support, result_weapon)
  return {
    id = id,
    name = name,
    base_weapon = base_weapon,
    result_weapon = result_weapon,
    branch = "fusion",
    required_weapon_level = 10,
    required_passives = {
      { id = support, min_level = 1 },
    },
    trigger = "level_up",
    consume_passives = true,
    weapon_slot_bonus = 1,
    max_weapon_capacity = 6,
  }
end

return {
  kazoo_studio = fusion(
    "kazoo_studio",
    "Airflow Brass Fusion",
    "kazoo_pistol",
    "breath_control",
    "brass_barrage"),

  bass_supernova = fusion(
    "bass_supernova",
    "Amplified Bass Fusion",
    "bass_drop",
    "power_amplifier",
    "subwoofer_supernova"),

  cymbal_ovation = fusion(
    "cymbal_ovation",
    "Quickstep Cymbal Fusion",
    "cymbal_slicer",
    "quickstep",
    "orbital_ovation"),

  feedback_solo = fusion(
    "feedback_solo",
    "Overdriven Feedback Fusion",
    "feedback_loop",
    "overdrive_pedal",
    "improvised_solo"),

  drum_thunderhead = fusion(
    "drum_thunderhead",
    "Encore Drum Fusion",
    "drum_circle",
    "encore",
    "thunderhead_ensemble"),

  trumpet_fortissimo = fusion(
    "trumpet_fortissimo",
    "Armored Trumpet Fusion",
    "trumpet_burst",
    "safety_vest",
    "golden_fortissimo"),

  vinyl_gravity = fusion(
    "vinyl_gravity",
    "Magnetic Vinyl Fusion",
    "vinyl_scratch",
    "pickup_magnet",
    "gravity_groove"),

  synth_crescendo = fusion(
    "synth_crescendo",
    "Echoing Synth Fusion",
    "synth_wave",
    "echo_chamber",
    "neon_crescendo"),

  triangle_prism = fusion(
    "triangle_prism", "Prismatic Triangle Fusion",
    "triangle_tracer", "breath_control", "prismatic_triangle"),

  cello_impaler = fusion(
    "cello_impaler", "Velvet Cello Fusion",
    "cello_lance", "power_amplifier", "velvet_impaler"),

  maraca_superorbit = fusion(
    "maraca_superorbit", "Carnival Maraca Fusion",
    "maraca_orbit", "quickstep", "carnival_superorbit"),

  fork_rupture = fusion(
    "fork_rupture", "Resonance Fork Fusion",
    "tuning_fork", "overdrive_pedal", "resonance_rupture"),

  keytar_stadium = fusion(
    "keytar_stadium", "Stadium Keytar Fusion",
    "keytar_chord", "encore", "stadium_keytar"),

  bell_cathedral = fusion(
    "bell_cathedral", "Cathedral Bell Fusion",
    "bell_tower", "safety_vest", "cathedral_overdrive"),

  tape_infinite = fusion(
    "tape_infinite", "Infinite Mixtape Fusion",
    "tape_repeater", "pickup_magnet", "infinite_mixtape"),

  harp_aurora = fusion(
    "harp_aurora", "Aurora Harp Fusion",
    "laser_harp", "echo_chamber", "aurora_harp"),
}
