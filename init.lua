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


-- Import color theme based on environment variable NVIM_THEME
local default_color_scheme = 'catppuccin'
local env_var_nvim_theme = os.getenv 'NVIM_THEME' or default_color_scheme

-- Define a table of theme modules
local themes = {
  nord = 'themes.nord',
  onedark = 'themes.onedark',
  catppuccin = 'themes.catppuccin',
}





vim.opt.rtp:prepend(lazypath)
require "core.options"
require "core.keymaps"
require("snippets")
require("lazy").setup("plugins")

