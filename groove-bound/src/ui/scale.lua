local Scale = {}

function Scale.factor(w, h)
  w = w or love.graphics.getWidth()
  h = h or love.graphics.getHeight()
  return math.max(1, math.min(w / 1280, h / 720))
end

function Scale.dimensions()
  local w, h = love.graphics.getDimensions()
  local factor = Scale.factor(w, h)
  return w / factor, h / factor, factor
end

function Scale.begin()
  local w, h, factor = Scale.dimensions()
  love.graphics.push()
  love.graphics.scale(factor, factor)
  return w, h, factor
end

function Scale.finish()
  love.graphics.pop()
end

function Scale.point(x, y, factor)
  factor = factor or Scale.factor()
  return x / factor, y / factor
end

return Scale
