--- The full color table for a variant: the palette plus derived tints,
--- diff and diagnostic backgrounds, git colors and the 16 terminal
--- colors. Key names follow tokyonight's (`bg_dark`, `fg_dark`, `blue`,
--- `magenta`, `teal`, `orange`, ...) so code written against that
--- palette works unchanged.
local util = require("kage.util")

local M = {}

---@alias kage.Variant "shadow"|"dawn"

---@class kage.Colors: kage.Palette
---@field variant kage.Variant
---@field light boolean
---@field lantern string alias of orange
---@field violet string alias of purple
---@field none string
---@field bg_visual string
---@field bg_search string
---@field bg_cursearch string
---@field bg_sidebar string
---@field bg_statusline string
---@field bg_popup string
---@field fg_float string
---@field fg_sidebar string
---@field error string
---@field warning string
---@field info string
---@field hint string
---@field todo string
---@field diff { add: string, delete: string, change: string, text: string }
---@field git { add: string, change: string, delete: string, ignore: string }
---@field diag_bg { error: string, warning: string, info: string, hint: string }
---@field terminal string[] 16 ANSI colors, index 1 is color0

---@param variant kage.Variant
---@return kage.Colors
function M.get(variant)
  local p = require("kage.palette")[variant] or require("kage.palette").shadow
  local light = variant == "dawn"
  ---@type kage.Colors
  local c = vim.deepcopy(p)
  c.variant = variant
  c.light = light
  c.none = "NONE"
  c.lantern = p.orange
  c.violet = p.purple

  c.bg_visual = util.blend(p.purple, p.bg, light and 0.16 or 0.22)
  c.bg_search = util.blend(p.orange, p.bg, light and 0.2 or 0.28)
  c.bg_cursearch = p.orange
  c.bg_sidebar = p.bg_dark
  c.bg_statusline = p.bg_dark
  c.bg_popup = p.bg_float
  c.fg_float = p.fg
  c.fg_sidebar = p.fg_dark

  c.error = p.red
  c.warning = p.yellow
  c.info = p.blue
  c.hint = p.teal
  c.todo = p.blue

  local tint = light and 0.12 or 0.14
  c.diff = {
    add = util.blend(p.green, p.bg, tint),
    delete = util.blend(p.red, p.bg, tint),
    change = util.blend(p.blue, p.bg, light and 0.1 or 0.12),
    text = util.blend(p.blue, p.bg, light and 0.22 or 0.26),
  }
  c.git = { add = p.green, change = p.blue, delete = p.red, ignore = p.fg_gutter }
  c.diag_bg = {
    error = util.blend(p.red, p.bg, 0.1),
    warning = util.blend(p.yellow, p.bg, 0.1),
    info = util.blend(p.blue, p.bg, 0.1),
    hint = util.blend(p.teal, p.bg, 0.1),
  }

  -- normal 0 to 7, then bright 8 to 15: brights are the accents shifted
  -- toward the text color, black and white are set by hand
  local shift = light and util.darken or util.lighten
  local amount = light and 0.12 or 0.18
  local normal = { light and "#2b2735" or "#1b1920", p.red, p.green, p.yellow, p.blue, p.purple, p.cyan }
  normal[8] = light and "#d8d3e0" or "#cfcad9"
  local bright = { light and "#6d6780" or "#4a4556" }
  for i = 2, 7 do
    bright[i] = shift(normal[i], amount)
  end
  bright[8] = light and "#ffffff" or p.fg_strong
  c.terminal = vim.list_extend(vim.list_extend({}, normal), bright)
  return c
end

return M
