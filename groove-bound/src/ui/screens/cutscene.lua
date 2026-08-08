local class = require("src.core.class")
local Fonts = require("src.ui.fonts")
local settings = require("src.config.settings")
local Hints = require("src.ui.controller_hints")

local CutsceneScreen = class()
CutsceneScreen.kind = "cutscene"

local VIDEO_DIRECTORY = "assets/video/runtime"

local speaker_characters = {
  JOE = "joe",
  LYRA = "lyra",
}

local function words(text)
  local result = {}
  for word in text:gmatch("%S+") do result[#result + 1] = word end
  return result
end

local function contains(rect, x, y)
  return rect and x >= rect.x and y >= rect.y
    and x <= rect.x + rect.w and y <= rect.y + rect.h
end

function CutsceneScreen:init(app, scene, opts)
  self.app = app
  self.scene = assert(scene)
  self.opts = opts or {}
  self.index = 1
  self.elapsed = 0
  self.fade = 1
  self.skip_armed = 0
  self.video = nil
  self.video_source = nil
  self.video_paused = false
  self.video_ended = false
  self.video_duration = 0
  self.video_rect = nil
  self.video_skip_rect = nil
  self.video_next_rect = nil
  self.video_replay_rect = nil
end

function CutsceneScreen:enter()
  self.app.log.info("state", "Cutscene entered: " .. self.scene.id)
  self:_load_video()
end

function CutsceneScreen:exit()
  if self.video then self.video:pause() end
  if self.video_source and self.video_source.stop then self.video_source:stop() end
  if self.app.music and self.app.music.set_suspended then
    self.app.music:set_suspended(false)
  end
end

function CutsceneScreen:update(dt)
  if self.video then
    if self.video_source then
      local options = self.app.profile and self.app.profile.options or {}
      self.video_source:setVolume(options.master_volume or 1)
    end
    if not self.video_paused and not self.video_ended then
      local at_end = self.video_duration > 0
        and self.video:tell() >= self.video_duration - 0.08
      if at_end or (self.elapsed > 0.35 and not self.video:isPlaying()) then
        self.video_ended = true
        self.video_paused = false
      end
    end
  end
  self.elapsed = self.elapsed + dt
  self.fade = math.max(0, self.fade - dt * 2.8)
  self.skip_armed = math.max(0, self.skip_armed - dt)
end

function CutsceneScreen:_video_path()
  if not love or not love.filesystem or not love.filesystem.getDirectoryItems then
    return nil
  end
  local info = love.filesystem.getInfo(VIDEO_DIRECTORY, "directory")
  if not info then return nil end
  for _, filename in ipairs(love.filesystem.getDirectoryItems(VIDEO_DIRECTORY)) do
    local mapped = filename:match("^cutscene%-%d+%-(.+)%.ogv$")
    if mapped and (mapped == self.scene.id
      or mapped:gsub("%-", "_") == self.scene.id)
    then
      return VIDEO_DIRECTORY .. "/" .. filename
    end
  end
  return nil
end

function CutsceneScreen:_load_video()
  local path = self:_video_path()
  if not path or not love.graphics.newVideo then return false end
  local ok, video = pcall(love.graphics.newVideo, path, { audio = true })
  if not ok or not video then
    self.app.log.info("state", "Video fallback for " .. self.scene.id)
    return false
  end
  self.video = video
  self.video_source = video:getSource()
  self.video_duration = self.video_source and self.video_source:getDuration() or 0
  if self.video_source then
    local options = self.app.profile and self.app.profile.options or {}
    self.video_source:setVolume(options.master_volume or 1)
  end
  self.video:play()
  if self.app.music and self.app.music.set_suspended then
    self.app.music:set_suspended(true)
  end
  return true
end

function CutsceneScreen:_toggle_video()
  if not self.video or self.video_ended then return end
  if self.video_paused then
    self.video:play()
    self.video_paused = false
  else
    self.video:pause()
    self.video_paused = true
  end
end

function CutsceneScreen:_replay_video()
  if not self.video then return end
  self.video:rewind()
  self.video:play()
  self.elapsed = 0
  self.video_ended = false
  self.video_paused = false
end

function CutsceneScreen:_finish()
  if self.opts.on_complete then
    self.opts.on_complete(self.app)
  else
    self.app.states:pop(self.opts.result)
  end
end

function CutsceneScreen:_advance()
  if self.index >= #self.scene.slides then
    self:_finish()
    return
  end
  self.index = self.index + 1
  self.elapsed = 0
  self.fade = 1
end

function CutsceneScreen:_reveal_duration()
  local slide = self.scene.slides[self.index]
  return 0.28 + math.max(0, #words(slide.text) - 1) * 0.18
end

function CutsceneScreen:_confirm()
  if self.elapsed < self:_reveal_duration() then
    self.elapsed = self:_reveal_duration()
    return
  end
  self:_advance()
end

function CutsceneScreen:_back()
  if self.index <= 1 then return end
  self.index = self.index - 1
  self.elapsed = 0
  self.fade = 1
end

function CutsceneScreen:presentation()
  local slide = self.scene.slides[self.index]
  local tokens = words(slide.text)
  local reveal_delay = 0.28
  local word_interval = 0.18
  local speaking_time = self.elapsed - reveal_delay
  local revealed = 0
  if speaking_time >= 0 then
    revealed = math.min(#tokens, math.floor(speaking_time / word_interval) + 1)
  end
  local visible = {}
  for index = 1, revealed do visible[index] = tokens[index] end
  local actively_speaking = revealed > 0 and revealed < #tokens
  return {
    text = table.concat(visible, " "),
    revealed = revealed,
    word_count = #tokens,
    character = speaker_characters[slide.speaker],
    mouth_open = actively_speaking
      and math.floor(speaking_time / 0.10) % 2 == 0,
  }
end

function CutsceneScreen:dialogue_layout(w, h)
  local panel_w = math.min(900, w - 120)
  local panel_x = (w - panel_w) / 2
  local panel_h = math.min(250, h * 0.31)
  local panel_y = h - panel_h - 74
  local portrait_w = math.min(340, panel_w * 0.38)
  return {
    panel_x = panel_x,
    panel_y = panel_y,
    panel_w = panel_w,
    panel_h = panel_h,
    portrait_w = portrait_w,
    text_x = panel_x + portrait_w + 18,
    text_w = panel_w - portrait_w - 42,
  }
end

function CutsceneScreen:talking_pose(w, h)
  local layout = self:dialogue_layout(w, h)
  local head_bleed = math.min(145, h * 0.18)
  return {
    x = layout.panel_x + layout.portrait_w * 0.52,
    bottom = layout.panel_y + layout.panel_h + 48,
    height = math.min(455, layout.panel_h * 1.78),
    rotation = 0,
    clip_x = layout.panel_x,
    clip_y = layout.panel_y - head_bleed,
    clip_w = layout.portrait_w + 10,
    clip_h = layout.panel_h + head_bleed,
  }
end

function CutsceneScreen:_draw_video(w, h)
  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.rectangle("fill", 0, 0, w, h)
  local video_w, video_h = self.video:getDimensions()
  local scale = math.min(w / video_w, h / video_h)
  local draw_w, draw_h = video_w * scale, video_h * scale
  local draw_x, draw_y = (w - draw_w) / 2, (h - draw_h) / 2
  self.video_rect = { x = draw_x, y = draw_y, w = draw_w, h = draw_h }
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.video, draw_x, draw_y, 0, scale, scale)

  love.graphics.setFont(Fonts.get(17))
  if self.video_ended then
    love.graphics.setColor(0.01, 0.005, 0.04, 0.78)
    love.graphics.rectangle("fill", 0, h - 112, w, 112)
    local button_w, button_h, gap = 190, 48, 16
    local start_x = (w - button_w * 2 - gap) / 2
    self.video_replay_rect = {
      x = start_x, y = h - 82, w = button_w, h = button_h,
    }
    self.video_next_rect = {
      x = start_x + button_w + gap, y = h - 82, w = button_w, h = button_h,
    }
    for _, entry in ipairs({
      { rect = self.video_replay_rect, label = "REPLAY", color = { 0.30, 0.78, 1.0, 1 } },
      { rect = self.video_next_rect, label = "NEXT", color = { 1.0, 0.72, 0.20, 1 } },
    }) do
      love.graphics.setColor(0.08, 0.04, 0.14, 0.96)
      love.graphics.rectangle("fill", entry.rect.x, entry.rect.y,
        entry.rect.w, entry.rect.h, 8, 8)
      love.graphics.setColor(entry.color)
      love.graphics.setLineWidth(2)
      love.graphics.rectangle("line", entry.rect.x, entry.rect.y,
        entry.rect.w, entry.rect.h, 8, 8)
      love.graphics.printf(entry.label, entry.rect.x,
        entry.rect.y + 14, entry.rect.w, "center")
    end
    love.graphics.setLineWidth(1)
    love.graphics.setFont(Fonts.get(12))
    love.graphics.setColor(0.72, 0.70, 0.82, 0.82)
    love.graphics.printf(
      "Click outside the buttons to continue",
      0, h - 106, w, "center")
  else
    self.video_replay_rect = nil
    self.video_next_rect = nil
    self.video_skip_rect = { x = w - 156, y = h - 66, w = 124, h = 42 }
    love.graphics.setColor(0.03, 0.015, 0.08, 0.88)
    love.graphics.rectangle("fill", self.video_skip_rect.x,
      self.video_skip_rect.y, self.video_skip_rect.w,
      self.video_skip_rect.h, 8, 8)
    love.graphics.setColor(1.0, 0.72, 0.20, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", self.video_skip_rect.x,
      self.video_skip_rect.y, self.video_skip_rect.w,
      self.video_skip_rect.h, 8, 8)
    love.graphics.printf("SKIP", self.video_skip_rect.x,
      self.video_skip_rect.y + 11, self.video_skip_rect.w, "center")
    love.graphics.setLineWidth(1)
    love.graphics.setFont(Fonts.get(13))
    love.graphics.setColor(0.78, 0.76, 0.86, 0.90)
    love.graphics.printf(self.video_paused
      and "PAUSED  •  Click video to continue"
      or "Click video to pause",
      24, h - 47, w - 210, "left")
  end
end

function CutsceneScreen:draw()
  local w, h = love.graphics.getDimensions()
  if self.video then
    self:_draw_video(w, h)
    return
  end
  local slide = self.scene.slides[self.index]
  local presentation = self:presentation()
  local draw_w, draw_h = w, h

  love.graphics.setColor(settings.ui.background_color)
  love.graphics.rectangle("fill", 0, 0, w, h)
  self.app.assets:draw_cutscene(
    slide.atlas, slide.col, slide.row,
    (w - draw_w) / 2, (h - draw_h) / 2,
    draw_w, draw_h)

  -- Slow moving light bands keep the illustrated panel alive without
  -- competing with the dialogue.
  for band = 1, 3 do
    local x = ((self.elapsed * (34 + band * 9) + band * w * 0.37) % (w * 1.5))
      - w * 0.25
    love.graphics.setColor(0.18, 0.82, 1.0, 0.025 + band * 0.008)
    love.graphics.polygon("fill",
      x - 90, 0, x + 18, 0, x + 230, h, x + 80, h)
  end

  love.graphics.setColor(0.015, 0.01, 0.05, 0.34)
  love.graphics.rectangle("fill", 0, 0, w, h)

  local layout = self:dialogue_layout(w, h)
  local panel_w, panel_x = layout.panel_w, layout.panel_x
  local panel_y, panel_h = layout.panel_y, layout.panel_h
  love.graphics.setColor(0.02, 0.012, 0.07, 0.78)
  love.graphics.rectangle("fill", panel_x, panel_y, panel_w, panel_h, 14, 14)

  love.graphics.setColor(0.22, 0.90, 1.0, 0.45)
  love.graphics.setLineWidth(2)
  love.graphics.rectangle("line", panel_x, panel_y, panel_w, panel_h, 14, 14)

  if presentation.character then
    love.graphics.setColor(0.12, 0.08, 0.22, 0.64)
    love.graphics.rectangle(
      "fill", panel_x + 2, panel_y + 2,
      layout.portrait_w, panel_h - 4, 12, 12)
    local pose = self:talking_pose(w, h)
    local previous_scissor = { love.graphics.getScissor() }
    love.graphics.setScissor(
      pose.clip_x, pose.clip_y, pose.clip_w, pose.clip_h)
    self.app.assets:draw_talking_character(
      presentation.character,
      presentation.mouth_open and 2 or 1,
      pose.x,
      pose.bottom,
      pose.height,
      { rotation = pose.rotation })
    if previous_scissor[1] then
      love.graphics.setScissor(
        previous_scissor[1], previous_scissor[2],
        previous_scissor[3], previous_scissor[4])
    else
      love.graphics.setScissor()
    end
  end

  love.graphics.setFont(Fonts.get(17))
  love.graphics.setColor(0.72, 0.70, 0.84, 1)
  love.graphics.print(self.scene.title, 54, 32)
  love.graphics.printf(
    string.format("%02d / %02d", self.index, #self.scene.slides),
    0, 34, w - 54, "right")

  love.graphics.setFont(Fonts.get(21))
  love.graphics.setColor(1.0, 0.76, 0.22, 1)
  local copy_x = presentation.character and layout.text_x or panel_x + 28
  local copy_w = presentation.character and layout.text_w or panel_w - 56
  love.graphics.printf(slide.speaker, copy_x, panel_y + 25, copy_w, "center")

  love.graphics.setFont(Fonts.get(27))
  love.graphics.setColor(settings.ui.text_color)
  love.graphics.printf(
    presentation.text,
    copy_x,
    panel_y + panel_h * 0.47,
    copy_w,
    "center")

  local progress = presentation.word_count > 0
    and presentation.revealed / presentation.word_count or 0
  love.graphics.setColor(0.12, 0.10, 0.20, 0.92)
  local progress_x = presentation.character and layout.text_x or panel_x + 54
  local progress_w = presentation.character and layout.text_w or panel_w - 108
  love.graphics.rectangle("fill", progress_x, panel_y + panel_h - 28,
    progress_w, 4, 2, 2)
  love.graphics.setColor(1.0, 0.62, 0.22, 0.9)
  love.graphics.rectangle("fill", progress_x, panel_y + panel_h - 28,
    progress_w * progress, 4, 2, 2)

  love.graphics.setColor(0.015, 0.01, 0.05, 0.86)
  love.graphics.rectangle("fill", 0, h - 38, w, 38)
  love.graphics.setFont(Fonts.get(15))
  love.graphics.setColor(0.70, 0.68, 0.80, 1)
  Hints.draw({
    { symbol = "cross", label = presentation.revealed < presentation.word_count
      and "Show sentence" or "Continue" },
    { symbol = "square", label = "Previous" },
    { symbol = "circle", label = "Skip (press twice)" },
    { symbol = "dpad", label = "Left / right" },
  }, h - 29, w, { font_size = 13, glyph_size = 18, gap = 17 })

  if self.skip_armed > 0 then
    love.graphics.setColor(0.04, 0.02, 0.09, 0.96)
    love.graphics.rectangle("fill", w / 2 - 260, h / 2 - 46, 520, 92, 8, 8)
    love.graphics.setColor(1.0, 0.72, 0.22, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", w / 2 - 260, h / 2 - 46, 520, 92, 8, 8)
    love.graphics.setFont(Fonts.get(20))
    love.graphics.printf(
      "Press Esc again to skip this first-draft story scene.",
      w / 2 - 230, h / 2 - 13, 460, "center")
  end

  if self.fade > 0 then
    love.graphics.setColor(0, 0, 0, self.fade)
    love.graphics.rectangle("fill", 0, 0, w, h)
  end
end

function CutsceneScreen:keypressed(key)
  if self.video then
    if self.video_ended then
      if key == "x" then self:_replay_video() return true end
      if key == "return" or key == "space" or key == "right" then
        self:_finish()
        return true
      end
    elseif key == "return" or key == "space" then
      self:_toggle_video()
      return true
    end
    return false
  end
  if key == "return" or key == "space" or key == "right" or key == "x" then
    self:_confirm()
    return true
  elseif key == "left" then
    self:_back()
    return true
  elseif key == "escape" then
    if self.skip_armed > 0 then
      self:_finish()
    else
      self.skip_armed = 2.5
    end
    return true
  end
  return false
end

function CutsceneScreen:mousepressed(x, y, button)
  if button ~= 1 then return false end
  if self.video then
    if self.video_ended then
      if contains(self.video_replay_rect, x, y) then
        self:_replay_video()
      else
        self:_finish()
      end
      return true
    end
    if contains(self.video_skip_rect, x, y) then
      self:_finish()
    elseif contains(self.video_rect, x, y) then
      self:_toggle_video()
    end
    return true
  end
  if button == 1 then self:_confirm() return true end
  return false
end

function CutsceneScreen:gamepadpressed(_, button)
  if self.video then
    if self.video_ended then
      if button == "x" then self:_replay_video() return true end
      if button == "a" then self:_finish() return true end
    elseif button == "a" then
      self:_toggle_video()
      return true
    end
    return false
  end
  if button == "a" then return self:keypressed("return") end
  if button == "x" then return self:keypressed("left") end
  if button == "b" then return self:keypressed("escape") end
  if button == "dpleft" then return self:keypressed("left") end
  if button == "dpright" then return self:keypressed("right") end
  return false
end

return CutsceneScreen
