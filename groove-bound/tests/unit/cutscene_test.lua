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

T["non-character narration has no talking sprite"] = function()
  local screen = fresh("NARRATOR", "Backbeat never slept")
  screen:update(0.5)
  H.is_nil(screen:presentation().character)
end

return T
