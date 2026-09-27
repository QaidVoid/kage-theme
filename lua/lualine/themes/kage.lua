-- lualine theme for kage; follows the active variant.
local c = require("kage").colors()

local function mode(color)
  return {
    a = { fg = c.bg_dark, bg = color, gui = "bold" },
    b = { fg = color, bg = c.bg_raised },
    c = { fg = c.fg_dark, bg = c.bg_statusline },
  }
end

return {
  normal = mode(c.lantern),
  insert = mode(c.green),
  visual = mode(c.purple),
  replace = mode(c.red),
  command = mode(c.yellow),
  terminal = mode(c.cyan),
  inactive = {
    a = { fg = c.fg_gutter, bg = c.bg_statusline },
    b = { fg = c.fg_gutter, bg = c.bg_statusline },
    c = { fg = c.fg_gutter, bg = c.bg_statusline },
  },
}
