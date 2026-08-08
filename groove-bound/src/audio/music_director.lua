local class = require("src.core.class")

local MusicDirector = class()

local function db_gain(db)
  return 10 ^ ((db or 0) / 20)
end

local function call(source, method, ...)
  if source and source[method] then return source[method](source, ...) end
end

function MusicDirector:init(catalog, opts)
  opts = opts or {}
  self.catalog = assert(catalog)
  self.source_factory = assert(opts.source_factory)
  self.master_volume = opts.master_volume or 1
  self.music_volume = opts.music_volume or 1
  self.crossfade_seconds = opts.crossfade_seconds or 0.35
  self.current = nil
  self.outgoing = nil
  self.preserved = nil
  self.preserved_stack = {}
  self.overlay = nil
  self.sting = nil
  self.pending = nil
  self.last_sting_serial = nil
  self.transition = "steady"
  self.focused = true
  self.suspended = false
end

function MusicDirector:_new_entry(cue, fade)
  local source = self.source_factory(cue.path)
  source:setLooping(cue.loop == true)
  local entry = {
    cue = cue,
    source = source,
    fade = fade or 1,
    duck = 1,
    applied_gain = 0,
  }
  self:_apply_gain(entry)
  source:play()
  return entry
end

function MusicDirector:_apply_gain(entry)
  if not entry then return end
  local value = self.master_volume * self.music_volume
    * (entry.cue.gain or 1) * (entry.fade or 1) * (entry.duck or 1)
  if self.suspended then value = 0 end
  entry.applied_gain = value
  entry.source:setVolume(value)
end

function MusicDirector:_stop(entry)
  if not entry then return end
  call(entry.source, "stop")
  call(entry.source, "release")
end

function MusicDirector:_stop_outgoing()
  self:_stop(self.outgoing)
  self.outgoing = nil
end

function MusicDirector:_push_preserved(entry)
  self.preserved_stack[#self.preserved_stack + 1] = entry
  self.preserved = entry
end

function MusicDirector:_pop_preserved()
  local index = #self.preserved_stack
  local entry = self.preserved_stack[index]
  self.preserved_stack[index] = nil
  self.preserved = self.preserved_stack[#self.preserved_stack]
  return entry
end

function MusicDirector:_clear_preserved()
  for _, entry in ipairs(self.preserved_stack) do self:_stop(entry) end
  self.preserved_stack = {}
  self.preserved = nil
end

function MusicDirector:_start_base(intent)
  local cue = assert(self.catalog:get(intent.cue),
    "unknown music cue " .. tostring(intent.cue))

  if self.current and self.current.cue.id == cue.id then
    self.current.duck = db_gain(intent.duck_db)
    self:_apply_gain(self.current)
    return
  end

  local saved = self.preserved_stack[#self.preserved_stack]
  if saved and saved.cue.id == cue.id then
    self:_stop(self.current)
    self:_stop_outgoing()
    self.current = self:_pop_preserved()
    self.current.duck = db_gain(intent.duck_db)
    self.current.fade = 1
    self:_apply_gain(self.current)
    self.current.source:play()
    self.transition = "steady"
    return
  end

  if not intent.preserve_underlay and #self.preserved_stack > 0 then
    self:_clear_preserved()
  end

  if intent.preserve_underlay and self.current then
    self:_stop_outgoing()
    self.current.source:pause()
    self:_push_preserved(self.current)
    self.current = nil
  end

  if intent.align == "bar" and not intent.immediate and self.current then
    if not self.pending or self.pending.cue ~= intent.cue then
      self.pending = intent
    end
    return
  end

  local immediate = intent.immediate or cue.transition == "immediate"
  if immediate or not self.current then
    self:_stop(self.current)
    self:_stop_outgoing()
    self.current = self:_new_entry(cue, 1)
    self.current.duck = db_gain(intent.duck_db)
    self:_apply_gain(self.current)
    self.transition = "steady"
    return
  end

  self:_stop_outgoing()
  self.outgoing = self.current
  self.outgoing.fade = 1
  self.current = self:_new_entry(cue, 0)
  self.current.duck = db_gain(intent.duck_db)
  self:_apply_gain(self.current)
  self.transition = "crossfade"
end

function MusicDirector:_sync_overlay(id)
  if self.overlay and self.overlay.cue.id == id then return end
  self:_stop(self.overlay)
  self.overlay = nil
  if not id then return end
  local cue = assert(self.catalog:get(id), "unknown music overlay " .. tostring(id))
  self.overlay = self:_new_entry(cue, 1)
  if self.current and self.current.source.tell and self.overlay.source.seek then
    local duration = cue.beats * 60 / cue.bpm
    self.overlay.source:seek(self.current.source:tell() % duration)
  end
  self:_apply_gain(self.overlay)
end

function MusicDirector:_sync_sting(event)
  if not event then return end
  local serial = type(event) == "table" and event.serial or tostring(event)
  local cue_id = type(event) == "table" and event.cue or event
  if self.last_sting_serial == serial then return end
  self.last_sting_serial = serial
  self:_stop(self.sting)
  local cue = assert(self.catalog:get(cue_id), "unknown music sting " .. tostring(cue_id))
  self.sting = self:_new_entry(cue, 1)
end

function MusicDirector:request(intent)
  if not intent or not intent.cue then return end
  self:_start_base(intent)
  self:_sync_overlay(intent.overlay)
  self:_sync_sting(intent.sting)
end

function MusicDirector:_update_pending(dt)
  if not self.pending or not self.current then return end
  local beat = 60 / self.current.cue.bpm
  local bar = beat * (self.current.cue.meter or 4)
  local phase = self.current.source:tell() % bar
  if phase <= 0.03 or bar - phase <= dt + 0.03 then
    local intent = self.pending
    self.pending = nil
    intent.align = nil
    self:_start_base(intent)
  end
end

function MusicDirector:update(dt)
  self:_update_pending(dt)
  if self.outgoing and self.current then
    local step = dt / math.max(0.01, self.crossfade_seconds)
    self.outgoing.fade = math.max(0, self.outgoing.fade - step)
    self.current.fade = math.min(1, self.current.fade + step)
    self:_apply_gain(self.outgoing)
    self:_apply_gain(self.current)
    if self.outgoing.fade <= 0 then
      self:_stop_outgoing()
      self.transition = "steady"
    end
  end
  if self.sting and self.sting.source.isPlaying
    and not self.sting.source:isPlaying()
  then
    self:_stop(self.sting)
    self.sting = nil
  end
end

function MusicDirector:set_volume(master, music)
  self.master_volume = master
  self.music_volume = music
  self:_apply_gain(self.current)
  self:_apply_gain(self.outgoing)
  for _, entry in ipairs(self.preserved_stack) do self:_apply_gain(entry) end
  self:_apply_gain(self.overlay)
  self:_apply_gain(self.sting)
end

function MusicDirector:set_suspended(value)
  self.suspended = value == true
  self:_apply_gain(self.current)
  self:_apply_gain(self.outgoing)
  for _, entry in ipairs(self.preserved_stack) do self:_apply_gain(entry) end
  self:_apply_gain(self.overlay)
  self:_apply_gain(self.sting)
end

function MusicDirector:_owned_entries()
  local entries = {}
  for _, entry in pairs({
    current = self.current,
    outgoing = self.outgoing,
    overlay = self.overlay,
    sting = self.sting,
  }) do
    entries[#entries + 1] = entry
  end
  for _, entry in ipairs(self.preserved_stack) do entries[#entries + 1] = entry end
  return entries
end

function MusicDirector:pause_all()
  if not self.focused then return end
  self.focused = false
  for _, entry in ipairs(self:_owned_entries()) do
    if entry then
      entry.resume_after_focus = not entry.source.isPlaying
        or entry.source:isPlaying()
      if entry.resume_after_focus then call(entry.source, "pause") end
    end
  end
end

function MusicDirector:resume_all()
  if self.focused then return end
  self.focused = true
  for _, entry in ipairs(self:_owned_entries()) do
    if entry and entry.resume_after_focus then
      entry.resume_after_focus = nil
      entry.source:play()
    end
  end
end

function MusicDirector:snapshot()
  return {
    cue = self.current and self.current.cue.id or nil,
    overlay = self.overlay and self.overlay.cue.id or nil,
    gain = self.current and self.current.applied_gain or 0,
    playback_time = self.current and self.current.source:tell() or 0,
    transition = self.transition,
    preserved_cue = self.preserved and self.preserved.cue.id or nil,
    pending_cue = self.pending and self.pending.cue or nil,
    sting = self.sting and self.sting.cue.id or nil,
    suspended = self.suspended,
  }
end

return MusicDirector
