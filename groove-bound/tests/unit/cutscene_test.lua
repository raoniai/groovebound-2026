local H = require("tests.helpers")
local CutsceneScreen = require("src.ui.screens.cutscene")

local T = {}

local function fresh(speaker, text)
  local app = {
    log = { info = function() end },
    states = { pop = function() end },
  }
  local screen = CutsceneScreen(app, {
    id = "test_scene",
    title = "TEST SCENE",
    slides = {
      {
        atlas = "prologue",
        col = 1,
        row = 1,
        speaker = speaker,
        text = text,
        duration = 100,
      },
    },
  })
  screen.auto = false
  return screen
end

T["dialogue reveals word by word and animates the active character mouth"] = function()
  local screen = fresh("JOE", "One two three four")
  H.eq(screen:presentation().text, "")

  screen:update(0.5)
  local speaking = screen:presentation()
  H.eq(speaking.text, "One two")
  H.eq(speaking.character, "joe")
  H.is_true(speaking.mouth_open)

  screen:update(10)
  local complete = screen:presentation()
  H.eq(complete.text, "One two three four")
  H.is_false(complete.mouth_open)
end

T["karaoke text and talking characters do not pulse or drift"] = function()
  local screen = fresh("LYRA", "Same pose changing mouth only")
  screen:update(0.5)
  H.is_nil(screen:presentation().pulse)

  local first = screen:talking_pose(1200, 800)
  screen:update(1.3)
  local second = screen:talking_pose(1200, 800)
  H.eq(first.x, second.x)
  H.eq(first.bottom, second.bottom)
  H.eq(first.height, second.height)
  H.eq(first.rotation, 0)
  H.eq(second.rotation, 0)
end

T["talking portrait sits on the left with head bleed and a cropped body"] = function()
  local screen = fresh("JOE", "Stay inside the dialogue frame")
  local layout = screen:dialogue_layout(1200, 800)
  local pose = screen:talking_pose(1200, 800)
  H.is_true(pose.x < layout.panel_x + layout.panel_w / 2)
  H.is_true(pose.clip_y < layout.panel_y)
  H.eq(pose.clip_y + pose.clip_h, layout.panel_y + layout.panel_h)
  H.is_true(pose.bottom > layout.panel_y + layout.panel_h)
  H.is_true(layout.text_x > pose.x)
end

T["non-character narration has no talking sprite"] = function()
  local screen = fresh("NARRATOR", "Backbeat never slept")
  screen:update(0.5)
  H.is_nil(screen:presentation().character)
end

T["completed sentences wait for explicit confirmation and never auto-advance"] = function()
  local completed = 0
  local app = {
    log = { info = function() end },
    states = { pop = function() completed = completed + 1 end },
  }
  local screen = CutsceneScreen(app, {
    id = "manual_scene",
    title = "MANUAL",
    slides = {
      { atlas = "prologue", col = 1, row = 1, speaker = "LYRA",
        text = "Wait for me", duration = 0.1 },
    },
  })
  screen:update(30)
  H.eq(screen:presentation().text, "Wait for me")
  H.eq(completed, 0)
  screen:keypressed("x")
  H.eq(completed, 1)
end

T["first confirmation reveals the full sentence before the next advances"] = function()
  local completed = 0
  local app = {
    log = { info = function() end },
    states = { pop = function() completed = completed + 1 end },
  }
  local screen = CutsceneScreen(app, {
    id = "reveal_scene", title = "REVEAL",
    slides = {
      { atlas = "prologue", col = 1, row = 1, speaker = "JOE",
        text = "One two three four", duration = 1 },
    },
  })
  screen:keypressed("return")
  H.eq(screen:presentation().text, "One two three four")
  H.eq(completed, 0)
  screen:keypressed("return")
  H.eq(completed, 1)
end

T["video cutscenes fade in and auto-finish two seconds after ending"] = function()
  local completed = 0
  local screen = fresh("JOE", "Video transition")
  screen.opts.on_complete = function() completed = completed + 1 end
  screen.video = {
    isPlaying = function() return false end,
    pause = function() end,
  }
  screen:update(0.2)
  H.is_true(screen:video_fade_alpha() > 0)
  screen:update(0.2)
  H.is_true(screen.video_ended)
  H.eq(completed, 0)
  screen:update(1.99)
  H.eq(completed, 0)
  H.is_true(screen:video_fade_alpha() > 0.9)
  screen:update(0.01)
  H.eq(completed, 1)
end

return T
