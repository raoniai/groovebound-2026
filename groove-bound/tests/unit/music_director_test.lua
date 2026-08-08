local H = require("tests.helpers")
local MusicDirector = require("src.audio.music_director")

local T = {}

local function fake_source()
  return {
    playing = false,
    looping = false,
    volume = 0,
    play = function(self) self.playing = true end,
    pause = function(self) self.playing = false; self.paused = true end,
    stop = function(self) self.playing = false end,
    release = function(self) self.released = true end,
    setLooping = function(self, value) self.looping = value end,
    setVolume = function(self, value) self.volume = value end,
    tell = function(self) return self.position or 0 end,
    seek = function(self, value) self.position = value end,
    isPlaying = function(self) return self.playing end,
  }
end

T["director starts one validated title loop at independent music gain"] = function()
  local created = {}
  local director = MusicDirector({
    get = function(_, id)
      if id == "title" then
        return {
          id = "title", path = "assets/music/01_title.ogg",
          loop = true, gain = 0.9,
        }
      end
    end,
  }, {
    source_factory = function(path)
      local source = fake_source()
      source.path = path
      created[#created + 1] = source
      return source
    end,
    master_volume = 0.8,
    music_volume = 0.5,
  })

  director:request({ cue = "title" }, { immediate = true })

  H.eq(#created, 1)
  H.eq(created[1].path, "assets/music/01_title.ogg")
  H.is_true(created[1].playing)
  H.is_true(created[1].looping)
  H.near(created[1].volume, 0.36)
  H.eq(director:snapshot().cue, "title")
end


local function director_fixture()
  local created = {}
  local cues = {
    title = { id = "title", path = "title.ogg", bpm = 112, beats = 32,
      loop = true, gain = 1, transition = "crossfade" },
    stage = { id = "stage", path = "stage.ogg", bpm = 132, beats = 32,
      loop = true, gain = 0.8, transition = "bar" },
    pause = { id = "pause", path = "pause.ogg", bpm = 92, beats = 32,
      loop = true, gain = 0.7, transition = "immediate" },
    low_health = { id = "low_health", path = "danger.ogg", bpm = 132,
      beats = 32, loop = true, gain = 0.4, transition = "overlay" },
  }
  local director = MusicDirector({ get = function(_, id) return cues[id] end }, {
    source_factory = function(path)
      local source = fake_source()
      source.path = path
      created[#created + 1] = source
      return source
    end,
    master_volume = 1,
    music_volume = 1,
    crossfade_seconds = 0.3,
  })
  return director, created
end

T["normal changes crossfade while urgent requests replace immediately"] = function()
  local director, created = director_fixture()
  director:request({ cue = "title", immediate = true })
  director:request({ cue = "stage" })
  H.eq(#created, 2)
  H.eq(director:snapshot().transition, "crossfade")
  director:update(0.31)
  H.is_false(created[1].playing)
  H.is_true(created[1].released)
  H.eq(director:snapshot().cue, "stage")
  director:request({ cue = "title", immediate = true })
  H.is_false(created[2].playing)
  H.eq(director:snapshot().cue, "title")
end

T["non-urgent wave changes wait for the current bar boundary"] = function()
  local director, created = director_fixture()
  director:request({ cue = "title", immediate = true })
  created[1].position = 1
  director:request({ cue = "stage", align = "bar" })
  H.eq(#created, 1)
  H.eq(director:snapshot().pending_cue, "stage")
  created[1].position = (4 * 60 / 112) - 0.02
  director:update(0.03)
  H.eq(#created, 2)
  H.eq(director:snapshot().cue, "stage")
end

T["stage clear sting is one-shot and cannot retrigger from a held event"] = function()
  local director, created = director_fixture()
  director.catalog.get = function(_, id)
    if id == "stage_clear_sting" then
      return { id = id, path = "sting.ogg", bpm = 124, beats = 8,
        loop = false, gain = 0.8, transition = "one_shot" }
    end
    return ({
      title = { id = "title", path = "title.ogg", bpm = 112, beats = 32,
        loop = true, gain = 1, transition = "crossfade" },
    })[id]
  end
  local intent = { cue = "title", immediate = true,
    sting = { cue = "stage_clear_sting", serial = 7 } }
  director:request(intent)
  director:request(intent)
  H.eq(#created, 2)
  H.eq(director:snapshot().sting, "stage_clear_sting")
  H.is_false(created[2].looping)
end

T["modal cue pauses and later restores the exact underlay cursor"] = function()
  local director, created = director_fixture()
  director:request({ cue = "stage", immediate = true })
  created[1].position = 5.25
  director:request({ cue = "pause", preserve_underlay = true, immediate = true })
  H.is_true(created[1].paused)
  H.eq(director:snapshot().preserved_cue, "stage")
  director:request({ cue = "stage", immediate = true })
  H.eq(#created, 2)
  H.is_true(created[1].playing)
  H.near(created[1].position, 5.25)
  H.eq(director:snapshot().cue, "stage")
end

T["nested modal cues restore each origin cursor in stack order"] = function()
  local director, created = director_fixture()
  director:request({ cue = "stage", immediate = true })
  created[1].position = 5.25
  director:request({ cue = "pause", preserve_underlay = true, immediate = true })
  created[2].position = 2.75
  director:request({ cue = "title", preserve_underlay = true, immediate = true })
  director:request({ cue = "pause", preserve_underlay = true, immediate = true })
  H.eq(#created, 3)
  H.near(created[2].position, 2.75)
  H.is_true(created[2].playing)
  director:request({ cue = "stage", immediate = true })
  H.eq(#created, 3)
  H.near(created[1].position, 5.25)
  H.is_true(created[1].playing)
end

T["volume changes apply live without restarting and overlay aligns to the base cursor"] = function()
  local director, created = director_fixture()
  director:request({ cue = "stage", immediate = true })
  created[1].position = 4.5
  director:request({ cue = "stage", overlay = "low_health" })
  H.eq(#created, 2)
  H.near(created[2].position, 4.5)
  director:set_volume(0.5, 0.25)
  H.near(created[1].volume, 0.1)
  H.near(created[2].volume, 0.05)
  H.eq(director:snapshot().overlay, "low_health")
end

T["focus pause and resume affect every owned source"] = function()
  local director, created = director_fixture()
  director:request({ cue = "stage", immediate = true, overlay = "low_health" })
  director:pause_all()
  H.is_false(created[1].playing)
  H.is_false(created[2].playing)
  director:resume_all()
  H.is_true(created[1].playing)
  H.is_true(created[2].playing)
end

return T
