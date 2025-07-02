-- Отключаем встроенный файловый менеджер netrw ДО всего остального
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

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

-- Автокоманда для перехода в папку при открытии (без Alpha)
vim.api.nvim_create_autocmd("VimEnter", {
  pattern = "*",
  callback = function()
    local arg = vim.fn.argv(0)
    if arg and arg ~= "" and vim.fn.isdirectory(arg) == 1 then
      pcall(vim.cmd, "cd " .. vim.fn.fnameescape(arg))
    end
  end,
})
