--- The kage palettes: the only place colors are written by hand.
--- Everything else (highlights, lualine, terminal and app extras,
--- PALETTE.md) derives from these two tables.
---@class kage.Palette
---@field bg string canvas
---@field bg_dark string sidebars, statusline, terminal black
---@field bg_float string floating windows
---@field bg_highlight string cursor line
---@field bg_raised string selected rows in menus
---@field fg string text
---@field fg_strong string headings, emphasis
---@field fg_dark string secondary text
---@field comment string comments
---@field fg_gutter string line numbers, guides
---@field border string window borders and separators
---@field orange string lantern: the accent
---@field purple string violet: keywords, swarms
---@field magenta string
---@field green string
---@field yellow string
---@field red string
---@field blue string
---@field cyan string
---@field teal string
---@field pink string
---@field mist string properties and fields
---@field sand string parameters
---@field operator string
---@field punct string

local M = {}

--- Dark variant: ink surfaces with a violet undertone, one warm lantern accent.
---@type kage.Palette
M.shadow = {
  bg = "#0f0e13",
  bg_dark = "#0b0a0e",
  bg_float = "#15131b",
  bg_highlight = "#17151d",
  bg_raised = "#221f2a",
  fg = "#cdc9d6",
  fg_strong = "#f4f1fa",
  fg_dark = "#9895a0",
  comment = "#6f6a7e",
  fg_gutter = "#46444c",
  border = "#2b2a30",
  orange = "#f2a65a",
  purple = "#a98bfa",
  magenta = "#c79bf2",
  green = "#8bd49c",
  yellow = "#e8c96a",
  red = "#f2727f",
  blue = "#9ab4ff",
  cyan = "#7dd3d0",
  teal = "#5fc9b0",
  pink = "#f29ac1",
  mist = "#b8b0d4",
  sand = "#e9c29a",
  operator = "#a39dba",
  punct = "#7c7690",
}

--- Light variant: ink on a violet-tinted paper, accents deepened to keep
--- 4.5:1 contrast.
---@type kage.Palette
M.dawn = {
  bg = "#f7f5f9",
  bg_dark = "#eeebf2",
  bg_float = "#ffffff",
  bg_highlight = "#efecf3",
  bg_raised = "#e4dfeb",
  fg = "#2b2735",
  fg_strong = "#15121c",
  fg_dark = "#56506a",
  comment = "#8a8499",
  fg_gutter = "#b4aec0",
  border = "#dcd7e3",
  orange = "#a8580f",
  purple = "#6a47cc",
  magenta = "#8a3fb5",
  green = "#2b7443",
  yellow = "#836409",
  red = "#bf3649",
  blue = "#3456c2",
  cyan = "#157a84",
  teal = "#1c7563",
  pink = "#ac3a7a",
  mist = "#5a5282",
  sand = "#935628",
  operator = "#5f5877",
  punct = "#7d7790",
}

return M
