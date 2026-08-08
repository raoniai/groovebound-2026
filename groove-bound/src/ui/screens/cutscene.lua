local class = require("src.core.class")
local Fonts = require("src.ui.fonts")
local settings = require("src.config.settings")

local CutsceneScreen = class()
CutsceneScreen.kind = "cutscene"

local speaker_characters = {
  JOE = "joe",
  LYRA = "lyra",
}

local function words(text)
  local result = {}
  for word in text:gmatch("%S+") do result[#result + 1] = word end
  return result
end

function CutsceneScreen:init(app, scene, opts)
  self.app = app
  self.scene = assert(scene)
  self.opts = opts or {}
  self.index = 1
  self.elapsed = 0
  self.auto = true
  self.fade = 1
  self.skip_armed = 0
end

function CutsceneScreen:enter()
  self.app.log.info("state", "Cutscene entered: " .. self.scene.id)
end

function CutsceneScreen:update(dt)
  self.elapsed = self.elapsed + dt
  self.fade = math.max(0, self.fade - dt * 2.8)
  self.skip_armed = math.max(0, self.skip_armed - dt)
  local slide = self.scene.slides[self.index]
  if self.auto and self.elapsed >= (slide.duration or 6) then
    self:_advance()
  end
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

function CutsceneScreen:talking_pose(w, h)
  return {
    x = w / 2,
    bottom = h + 26,
    height = math.min(390, h * 0.44),
    rotation = 0,
  }
end

function CutsceneScreen:draw()
  local w, h = love.graphics.getDimensions()
  local slide = self.scene.slides[self.index]
  local presentation = self:presentation()
  local zoom = 1.045 + math.min(0.07, self.elapsed * 0.004)
  local draw_w, draw_h = w * zoom, h * zoom
  local pan_x = math.sin(self.elapsed * 0.31 + self.index) * w * 0.026
  local pan_y = math.cos(self.elapsed * 0.23 + self.index * 0.7) * h * 0.018

  love.graphics.setColor(settings.ui.background_color)
  love.graphics.rectangle("fill", 0, 0, w, h)
  self.app.assets:draw_cutscene(
    slide.atlas, slide.col, slide.row,
    (w - draw_w) / 2 + pan_x, (h - draw_h) / 2 + pan_y,
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

  if presentation.character then
    local pose = self:talking_pose(w, h)
    self.app.assets:draw_talking_character(
      presentation.character,
      presentation.mouth_open and 2 or 1,
      pose.x,
      pose.bottom,
      pose.height,
      { rotation = pose.rotation })
  end

  local panel_w = math.min(900, w - 120)
  local panel_x = (w - panel_w) / 2
  local panel_y = h * 0.24
  local panel_h = math.min(250, h * 0.31)
  love.graphics.setColor(0.02, 0.012, 0.07, 0.78)
  love.graphics.rectangle("fill", panel_x, panel_y, panel_w, panel_h, 14, 14)
  love.graphics.setColor(0.22, 0.90, 1.0, 0.45)
  love.graphics.setLineWidth(2)
  love.graphics.rectangle("line", panel_x, panel_y, panel_w, panel_h, 14, 14)

  love.graphics.setFont(Fonts.get(17))
  love.graphics.setColor(0.72, 0.70, 0.84, 1)
  love.graphics.print(self.scene.title, 54, 32)
  love.graphics.printf(
    string.format("%02d / %02d", self.index, #self.scene.slides),
    0, 34, w - 54, "right")

  love.graphics.setFont(Fonts.get(21))
  love.graphics.setColor(1.0, 0.76, 0.22, 1)
  love.graphics.printf(slide.speaker, panel_x + 28, panel_y + 25,
    panel_w - 56, "center")

  love.graphics.setFont(Fonts.get(27))
  love.graphics.setColor(settings.ui.text_color)
  love.graphics.printf(
    presentation.text,
    panel_x + panel_w * 0.09,
    panel_y + panel_h * 0.47,
    panel_w * 0.82,
    "center")

  local progress = presentation.word_count > 0
    and presentation.revealed / presentation.word_count or 0
  love.graphics.setColor(0.12, 0.10, 0.20, 0.92)
  love.graphics.rectangle("fill", panel_x + 54, panel_y + panel_h - 28,
    panel_w - 108, 4, 2, 2)
  love.graphics.setColor(1.0, 0.62, 0.22, 0.9)
  love.graphics.rectangle("fill", panel_x + 54, panel_y + panel_h - 28,
    (panel_w - 108) * progress, 4, 2, 2)

  love.graphics.setColor(0.015, 0.01, 0.05, 0.86)
  love.graphics.rectangle("fill", 0, h - 38, w, 38)
  love.graphics.setFont(Fonts.get(15))
  love.graphics.setColor(0.70, 0.68, 0.80, 1)
  love.graphics.printf(
    (self.auto and "AUTO ON" or "AUTO OFF")
      .. "   •   Enter advance   •   ← previous   •   A auto   •   Esc skip",
    40, h - 27, w - 80, "center")

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
  if key == "return" or key == "space" or key == "right" then
    self:_advance()
    return true
  elseif key == "left" then
    self:_back()
    return true
  elseif key == "a" then
    self.auto = not self.auto
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

function CutsceneScreen:mousepressed(_, _, button)
  if button == 1 then self:_advance() return true end
  return false
end

function CutsceneScreen:gamepadpressed(_, button)
  if button == "a" then return self:keypressed("return") end
  if button == "x" then return self:keypressed("a") end
  if button == "b" then return self:keypressed("escape") end
  if button == "dpleft" then return self:keypressed("left") end
  return false
end

return CutsceneScreen
