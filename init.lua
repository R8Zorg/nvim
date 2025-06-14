local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end


local default_color_scheme = "catppuccin"
local themes = {
  catppuccin = 'plugins.themes.catppuccin',
  onedark = 'plugins.themes.onedark',
  nord = 'plugins.themes.nord',
  dracula = 'plugins.themes.dracula',
  sonokai = 'plugins.themes.sonokai',
  onenord = 'plugins.themes.onenord',
}

local selected_theme = os.getenv("NVIM_THEME")

-- load themes
if not themes[selected_theme] then
  -- vim.notify("Theme '" .. tostring(selected_theme) .. "' not found. Applying default theme.", vim.log.levels.WARN)
  selected_theme = default_color_scheme
end

local ok, err = pcall(require, themes[selected_theme])
if not ok then
  vim.notify("Error loading theme '" .. selected_theme .. "': " .. err, vim.log.levels.ERROR)
end

vim.opt.rtp:prepend(lazypath)
require "core.options"
require "core.keymaps"
require("snippets")
require("lazy").setup({
  require(themes[selected_theme]),
  { import = "plugins" },
})
