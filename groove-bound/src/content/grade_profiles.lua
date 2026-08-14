-- Versioned World Tour grading thresholds and per-world pillar weights.

return {
  revision = 1,
  thresholds = {
    { minimum = 40, grade = "D", title = "Soundcheck" },
    { minimum = 55, grade = "C", title = "On Beat" },
    { minimum = 70, grade = "B", title = "In the Pocket" },
    { minimum = 82, grade = "A", title = "Headliner" },
    { minimum = 92, grade = "S", title = "Perfect Groove" },
  },
  profiles = {
    funk_v1 = { groove = 30, impact = 20, control = 15, craft = 15, world_mastery = 20 },
    soul_v1 = { groove = 20, impact = 15, control = 25, craft = 20, world_mastery = 20 },
    disco_v1 = { groove = 25, impact = 15, control = 20, craft = 15, world_mastery = 25 },
    house_v1 = { groove = 30, impact = 20, control = 20, craft = 10, world_mastery = 20 },
    jazz_v1 = { groove = 20, impact = 20, control = 20, craft = 25, world_mastery = 15 },
    techno_v1 = { groove = 25, impact = 20, control = 25, craft = 15, world_mastery = 15 },
    cosmic_boogie_v1 = { groove = 30, impact = 15, control = 15, craft = 15, world_mastery = 25 },
    soulful_garage_v1 = { groove = 25, impact = 15, control = 20, craft = 15, world_mastery = 25 },
    future_funk_v1 = { groove = 25, impact = 25, control = 15, craft = 15, world_mastery = 20 },
  },
}
