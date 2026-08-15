local class = require("src.core.class")

local MusicCatalog = class()

function MusicCatalog:init(records, opts)
  self.records = records or {}
  self.file_exists = assert((opts or {}).file_exists)
  local paths = {}
  local transitions = {
    crossfade = true,
    immediate = true,
    bar = true,
    overlay = true,
    one_shot = true,
  }
  for id, cue in pairs(self.records) do
    assert(cue.id == id, "music cue id must match its table key")
    assert(type(cue.path) == "string" and cue.path ~= "", "music path required")
    assert(not paths[cue.path], "duplicate music path: " .. cue.path)
    paths[cue.path] = id
    assert(type(cue.bpm) == "number" and cue.bpm > 0,
      "music bpm must be positive")
    assert(type(cue.beats) == "number" and cue.beats > 0,
      "music beats must be positive")
    if cue.loop then
      assert(cue.beats % 32 == 0,
        "loop music cue must contain a multiple of 32 beats")
    end
    assert(type(cue.gain) == "number" and cue.gain >= 0 and cue.gain <= 1,
      "music gain must be between zero and one")
    assert(transitions[cue.transition], "unsupported music transition")
    assert(self.file_exists(cue.path), "missing music file: " .. cue.path)
  end
end

function MusicCatalog:get(id)
  return self.records[id]
end

return MusicCatalog
