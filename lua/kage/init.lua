--- kage: a dark and a light colorscheme from the kage GUI palette.
---
--- `:colorscheme kage` follows 'background' (dark gives shadow, light
--- gives dawn). `kage-shadow` and `kage-dawn` pick a variant and set
--- 'background' to match.
local M = {}

---@class kage.Styles
---@field comments? vim.api.keyset.highlight
---@field keywords? vim.api.keyset.highlight
---@field functions? vim.api.keyset.highlight
---@field variables? vim.api.keyset.highlight

---@class kage.Config
---@field variant? "auto"|kage.Variant `auto` follows 'background'
---@field transparent? boolean leave the terminal background showing
---@field terminal_colors? boolean set `vim.g.terminal_color_*`
---@field styles? kage.Styles extra attributes merged into these groups
---@field on_colors? fun(colors: kage.Colors) change colors before groups are built
---@field on_highlights? fun(hl: table<string, vim.api.keyset.highlight>, colors: kage.Colors) change groups before they are set

---@type kage.Config
local defaults = {
  variant = "auto",
  transparent = false,
  terminal_colors = true,
  styles = {
    comments = { italic = true },
    keywords = {},
    functions = {},
    variables = {},
  },
}

---@type kage.Config
M.config = vim.deepcopy(defaults)

--- Merge `opts` into the defaults. Call before `:colorscheme kage`.
---@param opts? kage.Config
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {})
end

---@param variant? "auto"|kage.Variant
---@return kage.Variant
local function resolve(variant)
  variant = variant or M.config.variant
  if variant == "auto" or variant == nil then
    return vim.o.background == "light" and "dawn" or "shadow"
  end
  return variant
end

--- The color table for a variant, after `on_colors`. Useful for
--- statuslines and other code that paints its own groups.
---@param variant? "auto"|kage.Variant
---@return kage.Colors
function M.colors(variant)
  local c = require("kage.colors").get(resolve(variant))
  if M.config.on_colors then
    M.config.on_colors(c)
  end
  return c
end

--- Apply the colorscheme. Called by the files under `colors/`.
---@param variant? "auto"|kage.Variant
function M.load(variant)
  local v = resolve(variant)
  local bg = v == "dawn" and "light" or "dark"
  if vim.o.background ~= bg then
    vim.o.background = bg
  end
  if vim.g.colors_name then
    vim.cmd("hi clear")
  end
  vim.o.termguicolors = true
  vim.g.colors_name = variant == nil and "kage" or ("kage-" .. v)

  local c = M.colors(v)
  local hl = require("kage.groups").get(c, M.config)
  if M.config.on_highlights then
    M.config.on_highlights(hl, c)
  end
  for name, spec in pairs(hl) do
    vim.api.nvim_set_hl(0, name, spec)
  end
  if M.config.terminal_colors then
    for i, color in ipairs(c.terminal) do
      vim.g["terminal_color_" .. (i - 1)] = color
    end
  end
end

return M
