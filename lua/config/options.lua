vim.opt.laststatus = 3
vim.opt.number = true
vim.opt.relativenumber = false

-- Настройки отступов
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.softtabstop = 2
vim.opt.smartindent = true

-- Убираем символы ~ в пустых строках
vim.opt.fillchars = { eob = " " }

-- Прозрачность
vim.cmd([[
  highlight Normal guibg=NONE ctermbg=NONE
  highlight NonText guibg=NONE ctermbg=NONE guifg=NONE
  highlight EndOfBuffer guibg=NONE ctermbg=NONE guifg=NONE
  highlight Whitespace guibg=NONE ctermbg=NONE guifg=NONE
  highlight SpecialKey guibg=NONE ctermbg=NONE guifg=NONE
  highlight LineNr guibg=NONE ctermbg=NONE
  highlight SignColumn guibg=NONE ctermbg=NONE
  highlight StatusLine guibg=NONE ctermbg=NONE
  highlight StatusLineNC guibg=NONE ctermbg=NONE
  highlight TabLine guibg=NONE ctermbg=NONE guifg=#565f89
  highlight TabLineFill guibg=NONE ctermbg=NONE
  highlight TabLineSel guibg=NONE ctermbg=NONE guifg=#c0caf5
  highlight VertSplit guibg=NONE ctermbg=NONE guifg=#565f89
  highlight WinSeparator guibg=NONE ctermbg=NONE guifg=#565f89
  highlight NeoTreeWinSeparator guibg=NONE ctermbg=NONE guifg=#565f89
]])

-- Автокоманда для принудительной прозрачности
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.cmd([[
      highlight Normal guibg=NONE ctermbg=NONE
      highlight NonText guibg=NONE ctermbg=NONE guifg=NONE
      highlight EndOfBuffer guibg=NONE ctermbg=NONE guifg=NONE
      highlight Whitespace guibg=NONE ctermbg=NONE guifg=NONE
      highlight SpecialKey guibg=NONE ctermbg=NONE guifg=NONE
      highlight StatusLine guibg=NONE ctermbg=NONE
      highlight StatusLineNC guibg=NONE ctermbg=NONE
      highlight TabLine guibg=NONE ctermbg=NONE guifg=#565f89
      highlight TabLineFill guibg=NONE ctermbg=NONE
      highlight TabLineSel guibg=NONE ctermbg=NONE guifg=#c0caf5
      highlight VertSplit guibg=NONE ctermbg=NONE guifg=#565f89
      highlight WinSeparator guibg=NONE ctermbg=NONE guifg=#565f89
      highlight NeoTreeWinSeparator guibg=NONE ctermbg=NONE guifg=#565f89
      highlight lualine_a_normal guibg=NONE ctermbg=NONE
      highlight lualine_b_normal guibg=NONE ctermbg=NONE
      highlight lualine_c_normal guibg=NONE ctermbg=NONE
      highlight lualine_x_normal guibg=NONE ctermbg=NONE
      highlight lualine_y_normal guibg=NONE ctermbg=NONE
      highlight lualine_z_normal guibg=NONE ctermbg=NONE
      highlight GitSignsAdd guifg=#9ece6a ctermfg=107
      highlight GitSignsChange guifg=#e0af68 ctermfg=179
      highlight GitSignsDelete guifg=#f7768e ctermfg=203
      highlight GitSignsAddLn guibg=#2a3441 ctermbg=238
      highlight GitSignsChangeLn guibg=#3a3441 ctermbg=238
      highlight GitSignsDeleteLn guibg=#3a2441 ctermbg=238
    ]])
  end,
})

-- Дополнительная автокоманда после загрузки lualine
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyLoad",
  callback = function()
    vim.cmd([[
      highlight lualine_a_normal guibg=NONE ctermbg=NONE
      highlight lualine_b_normal guibg=NONE ctermbg=NONE
      highlight lualine_c_normal guibg=NONE ctermbg=NONE
      highlight lualine_x_normal guibg=NONE ctermbg=NONE
      highlight lualine_y_normal guibg=NONE ctermbg=NONE
      highlight lualine_z_normal guibg=NONE ctermbg=NONE
    ]])
  end,
})

