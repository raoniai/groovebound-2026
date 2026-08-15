local NumberFormat = {}

function NumberFormat.integer(value)
  local number = math.floor(tonumber(value) or 0)
  local sign = number < 0 and "-" or ""
  local digits = tostring(math.abs(number))
  local formatted = digits:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  if formatted:sub(1, 1) == "," then formatted = formatted:sub(2) end
  return sign .. formatted
end

return NumberFormat
