local H = require("tests.helpers")
local MusicCatalog = require("src.audio.music_catalog")

local T = {}

T["validated catalog exposes the approved title cue"] = function()
  local catalog = MusicCatalog({
    title = {
      id = "title",
      path = "assets/music/01_title.ogg",
      bpm = 112,
      beats = 32,
      meter = 4,
      loop = true,
      gain = 1.0,
      transition = "crossfade",
    },
  }, {
    file_exists = function(path)
      return path == "assets/music/01_title.ogg"
    end,
  })

  H.eq(catalog:get("title").bpm, 112)
  H.eq(catalog:get("title").beats, 32)
end

T["loop cues must declare exactly 32 beats"] = function()
  local err = H.errors(function()
    MusicCatalog({
      broken = {
        id = "broken", path = "broken.ogg", bpm = 112, beats = 31,
        meter = 4, loop = true, gain = 1, transition = "crossfade",
      },
    }, { file_exists = function() return true end })
  end)
  H.is_true(err:find("32 beats", 1, true) ~= nil)
end

T["shipped title record resolves to its promoted runtime asset"] = function()
  local records = require("src.content.music")
  local catalog = MusicCatalog(records, {
    file_exists = function(path)
      local file = io.open(path, "rb")
      if not file then return false end
      file:close()
      return true
    end,
  })
  H.eq(catalog:get("title").path, "assets/music/01_title.ogg")
  local count = 0
  for _ in pairs(records) do count = count + 1 end
  H.eq(count, 31)
  H.eq(catalog:get("stage_clear_sting").beats, 8)
  H.is_false(catalog:get("stage_clear_sting").loop)
end

T["catalog rejects duplicate paths and unsupported transitions"] = function()
  local err = H.errors(function()
    MusicCatalog({
      a = { id = "a", path = "same.ogg", bpm = 100, beats = 32,
        meter = 4, loop = true, gain = 1, transition = "crossfade" },
      b = { id = "b", path = "same.ogg", bpm = 100, beats = 32,
        meter = 4, loop = true, gain = 1, transition = "crossfade" },
    }, { file_exists = function() return true end })
  end)
  H.is_true(err:find("duplicate music path", 1, true) ~= nil)
end

return T
