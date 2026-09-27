--- Color math shared by the highlight builder and the extras generator.
local M = {}

local function rgb(hex)
  hex = hex:gsub("#", "")
  return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
end

--- Mix `fg` over `bg` with `alpha` (0 gives `bg`, 1 gives `fg`).
---@param fg string
---@param bg string
---@param alpha number
---@return string
function M.blend(fg, bg, alpha)
  local fr, fg_, fb = rgb(fg)
  local br, bg_, bb = rgb(bg)
  local function mix(a, b)
    return math.floor(a * alpha + b * (1 - alpha) + 0.5)
  end
  return string.format("#%02x%02x%02x", mix(fr, br), mix(fg_, bg_), mix(fb, bb))
end

--- Move `hex` toward white by `amount` (0 to 1).
---@param hex string
---@param amount number
---@return string
function M.lighten(hex, amount)
  return M.blend("#ffffff", hex, amount)
end

--- Move `hex` toward black by `amount` (0 to 1).
---@param hex string
---@param amount number
---@return string
function M.darken(hex, amount)
  return M.blend("#000000", hex, amount)
end

return M
