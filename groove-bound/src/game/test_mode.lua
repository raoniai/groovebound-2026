-- One source of truth for the intentionally extreme Admin test preset.

local TestMode = {
  MULTIPLIER = 5,
}

function TestMode.factor(tuning)
  if tuning and tuning:get("test.enhanced_mode") then
    return TestMode.MULTIPLIER
  end
  return 1
end

return TestMode
