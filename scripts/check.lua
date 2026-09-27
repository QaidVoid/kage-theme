-- Load every variant headless and fail on errors, dangling highlight links
-- or syntax colors under 4.5:1 contrast. Run from the repo root:
--   nvim --headless --clean -l scripts/check.lua
vim.opt.rtp:prepend(vim.fn.getcwd())

local failures = {}
local function fail(msg)
  failures[#failures + 1] = msg
end

local function luminance(hex)
  local function channel(i)
    local v = tonumber(hex:sub(i, i + 1), 16) / 255
    return v <= 0.03928 and v / 12.92 or ((v + 0.055) / 1.055) ^ 2.4
  end
  return 0.2126 * channel(2) + 0.7152 * channel(4) + 0.0722 * channel(6)
end

local function contrast(a, b)
  local la, lb = luminance(a), luminance(b)
  if la < lb then
    la, lb = lb, la
  end
  return (la + 0.05) / (lb + 0.05)
end

local SYNTAX = {
  "fg",
  "fg_dark",
  "orange",
  "purple",
  "magenta",
  "green",
  "yellow",
  "red",
  "blue",
  "cyan",
  "teal",
  "pink",
  "mist",
  "sand",
  "operator",
}

for _, name in ipairs({ "kage", "kage-shadow", "kage-dawn" }) do
  local ok, err = pcall(vim.cmd.colorscheme, name)
  if not ok then
    fail(name .. ": " .. err)
  elseif vim.g.colors_name ~= name then
    fail(name .. ": colors_name is " .. tostring(vim.g.colors_name))
  end
end

vim.o.background = "light"
vim.cmd.colorscheme("kage")
if vim.g.colors_name ~= "kage" or vim.api.nvim_get_hl(0, { name = "Normal" }).bg ~= 0xf7f5f9 then
  fail("kage did not follow background=light")
end

for name, spec in pairs(vim.api.nvim_get_hl(0, {})) do
  if spec.link and vim.tbl_isempty(vim.api.nvim_get_hl(0, { name = spec.link })) then
    fail("dangling link: " .. name .. " -> " .. spec.link)
  end
end

for _, variant in ipairs({ "shadow", "dawn" }) do
  local c = require("kage.colors").get(variant)
  for _, key in ipairs(SYNTAX) do
    local ratio = contrast(c[key], c.bg)
    if ratio < 4.5 then
      fail(("%s.%s %s has %.2f:1 contrast on %s"):format(variant, key, c[key], ratio, c.bg))
    end
  end
  if #c.terminal ~= 16 then
    fail(variant .. ": expected 16 terminal colors, got " .. #c.terminal)
  end
end

local ok, theme = pcall(dofile, "lua/lualine/themes/kage.lua")
if not ok or not (theme.normal and theme.normal.a and theme.normal.a.bg) then
  fail("lualine theme did not load")
end

if #failures > 0 then
  io.stderr:write(table.concat(failures, "\n") .. "\n")
  os.exit(1)
end
print("ok: 3 colorschemes, links, contrast, lualine")
