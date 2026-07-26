local class = require("src.core.class")
local Fonts = require("src.ui.fonts")
local settings = require("src.config.settings")

local CutsceneScreen = class()

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

function CutsceneScreen:draw()
  local w, h = love.graphics.getDimensions()
  local slide = self.scene.slides[self.index]
  local image_h = h
  local zoom = 1.02 + math.min(0.035, self.elapsed * 0.0025)
  local draw_w, draw_h = w * zoom, image_h * zoom
  local pan = math.sin(self.elapsed * 0.18 + self.index) * w * 0.012

  love.graphics.setColor(settings.ui.background_color)
  love.graphics.rectangle("fill", 0, 0, w, h)
  self.app.assets:draw_cutscene(
    slide.atlas, slide.col, slide.row,
    (w - draw_w) / 2 + pan, (h - draw_h) / 2,
    draw_w, draw_h)

  love.graphics.setColor(0.015, 0.01, 0.05, 0.18)
  love.graphics.rectangle("fill", 0, 0, w, h)
  love.graphics.setColor(0.015, 0.01, 0.05, 0.94)
  love.graphics.rectangle("fill", 0, h - 220, w, 220)
  love.graphics.setColor(0.18, 0.92, 1.0, 0.85)
  love.graphics.rectangle("fill", 0, h - 220, w, 3)

  love.graphics.setFont(Fonts.get(17))
  love.graphics.setColor(0.72, 0.70, 0.84, 1)
  love.graphics.print(self.scene.title, 54, 32)
  love.graphics.printf(
    string.format("%02d / %02d", self.index, #self.scene.slides),
    0, 34, w - 54, "right")

  love.graphics.setFont(Fonts.get(23))
  love.graphics.setColor(1.0, 0.76, 0.22, 1)
  love.graphics.print(slide.speaker, 62, h - 188)
  love.graphics.setFont(Fonts.get(24))
  love.graphics.setColor(settings.ui.text_color)
  love.graphics.printf(slide.text, 62, h - 145, w - 124, "left")

  love.graphics.setFont(Fonts.get(15))
  love.graphics.setColor(0.70, 0.68, 0.80, 1)
  love.graphics.printf(
    (self.auto and "AUTO ON" or "AUTO OFF")
      .. "   •   Enter advance   •   ← previous   •   A auto   •   Esc skip",
    62, h - 42, w - 124, "right")

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
