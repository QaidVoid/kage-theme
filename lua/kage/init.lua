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
---@field cache? boolean reuse the built groups across sessions

---@type kage.Config
local defaults = {
  variant = "auto",
  transparent = false,
  terminal_colors = true,
  cache = true,
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

-- Building the colors and groups takes over a millisecond, so the result is
-- cached as bytecode that only sets the groups. The cache file name hashes
-- the variant, the config and the mtimes of kage's sources, so changing
-- any of them builds a fresh one. A hook counts as the file defining it.
local cache_dir = vim.fn.stdpath("cache") .. "/kage/"
local source_dir = debug.getinfo(1, "S").source:sub(2):match("^(.*)/")

local function mtime(path)
  local stat = vim.uv.fs_stat(path)
  return stat and (stat.mtime.sec .. "." .. stat.mtime.nsec)
end

--- A Lua literal for `v` with sorted keys. A function becomes where it is
--- defined and that file's mtime, so editing a hook gives a different one.
local function serialize(v)
  local t = type(v)
  if t == "table" then
    local keys = vim.tbl_keys(v)
    table.sort(keys, function(a, b)
      return tostring(a) < tostring(b)
    end)
    local out = {}
    for i, k in ipairs(keys) do
      out[i] = "[" .. serialize(k) .. "]=" .. serialize(v[k])
    end
    return "{" .. table.concat(out, ",") .. "}"
  elseif t == "function" then
    local info = debug.getinfo(v, "S")
    local file = info.source:sub(2)
    return ("%q"):format(("%s:%d:%s"):format(file, info.linedefined, mtime(file)))
  elseif t == "string" then
    return ("%q"):format(v)
  end
  return tostring(v)
end

-- djb2. vim.fn.sha256 would cost ~2ms on its first call.
local function hash(s)
  local h = 5381
  for i = 1, #s do
    h = bit.band(h * 33 + s:byte(i), 0xffffffff)
  end
  return bit.tohex(h)
end

---@param variant kage.Variant
local function cache_file(variant)
  local mtimes = {}
  local dir = vim.uv.fs_scandir(source_dir)
  local name = dir and vim.uv.fs_scandir_next(dir)
  while name do
    mtimes[name] = mtime(source_dir .. "/" .. name)
    name = vim.uv.fs_scandir_next(dir)
  end
  local key = serialize({ variant, M.config, mtimes })
  return ("%s%s-%s-%d.luac"):format(cache_dir, variant, hash(key), #key)
end

---@param file string
---@param variant kage.Variant
---@param hl table<string, vim.api.keyset.highlight>
---@param terminal? string[]
local function write_cache(file, variant, hl, terminal)
  local lines = { "local set = vim.api.nvim_set_hl" }
  for name, spec in pairs(hl) do
    lines[#lines + 1] = ("set(0, %q, %s)"):format(name, serialize(spec))
  end
  for i, color in ipairs(terminal or {}) do
    lines[#lines + 1] = ("vim.g.terminal_color_%d = %q"):format(i - 1, color)
  end
  local chunk = load(table.concat(lines, "\n"), "=kage-cache")
  for _, old in ipairs(vim.fn.glob(cache_dir .. variant .. "-*.luac", true, true)) do
    os.remove(old)
  end
  vim.fn.mkdir(cache_dir, "p")
  local f = chunk and io.open(file, "wb")
  if f then
    f:write(string.dump(chunk, true))
    f:close()
  end
end

--- Delete the cached groups; the next `:colorscheme kage` rebuilds them.
--- Needed only when a hook depends on state outside its own code.
function M.clear_cache()
  vim.fn.delete(cache_dir, "rf")
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

  local file = M.config.cache and cache_file(v)
  local cached = file and loadfile(file)
  if cached then
    return cached()
  end

  local c = M.colors(v)
  local hl = require("kage.groups").get(c, M.config)
  if M.config.on_highlights then
    M.config.on_highlights(hl, c)
  end
  for name, spec in pairs(hl) do
    vim.api.nvim_set_hl(0, name, spec)
  end
  local terminal = M.config.terminal_colors and c.terminal or nil
  for i, color in ipairs(terminal or {}) do
    vim.g["terminal_color_" .. (i - 1)] = color
  end
  if file then
    write_cache(file, v, hl, terminal)
  end
end

return M
