local CursorPolicy = {}

function CursorPolicy.visible_for(screen)
  return not screen or screen.kind ~= "run"
end

return CursorPolicy
