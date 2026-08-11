-- Volatile World Tour build bridge. This deliberately lives only on the app
-- instance: switching worlds in one open game carries the setlist, while a
-- fresh launch starts with the character's normal starter build.

local WorldTourSession = {}

function WorldTourSession.capture(app, character_id, progression)
  assert(type(progression) == "table", "progression snapshot required")
  app.world_tour_session = {
    character_id = character_id,
    progression = progression,
  }
  return app.world_tour_session
end

function WorldTourSession.get(app, character_id)
  local session = app.world_tour_session
  if not session or session.character_id ~= character_id then return nil end
  return session.progression
end

function WorldTourSession.clear(app)
  app.world_tour_session = nil
end

return WorldTourSession
