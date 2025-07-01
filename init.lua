-- Установка leader'а
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Инициализация Lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")

vim.cmd.colorscheme("tokyonight-night")

-- Настройки и бинды
require("config.options")
require("config.keymaps")
require("config.lsp")
require("config.conform")