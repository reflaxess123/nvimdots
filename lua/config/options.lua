vim.opt.laststatus = 3
vim.opt.showtabline = 2
vim.opt.number = true
vim.opt.relativenumber = false

-- Настройки отступов
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.softtabstop = 2
vim.opt.smartindent = true

-- Убираем задержки для keymaps
vim.opt.timeoutlen = 0
vim.opt.ttimeoutlen = 0

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
  highlight CursorLine guibg=NONE ctermbg=NONE
  highlight CursorColumn guibg=NONE ctermbg=NONE
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
      highlight CursorLine guibg=NONE ctermbg=NONE
      highlight CursorColumn guibg=NONE ctermbg=NONE
      highlight lualine_a_normal guibg=NONE ctermbg=NONE
      highlight lualine_b_normal guibg=NONE ctermbg=NONE
      highlight lualine_c_normal guibg=NONE ctermbg=NONE
      highlight lualine_x_normal guibg=NONE ctermbg=NONE
      highlight lualine_y_normal guibg=NONE ctermbg=NONE
      highlight lualine_z_normal guibg=NONE ctermbg=NONE
      highlight GitSignsAdd guifg=#9ece6a ctermfg=107
      highlight GitSignsChange guifg=#e0af68 ctermfg=179
      highlight GitSignsDelete guifg=#f7768e ctermfg=203
      highlight GitSignsAddLn guibg=NONE ctermbg=NONE
      highlight GitSignsChangeLn guibg=NONE ctermbg=NONE
      highlight GitSignsDeleteLn guibg=NONE ctermbg=NONE
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

-- Автокоманда для предотвращения проблем с Neo-tree при закрытии буферов
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function()
    -- Проверяем, что это Neo-tree и что мы попали сюда не намеренно
    if vim.bo.filetype == "neo-tree" then
      -- Считаем количество обычных окон (не Neo-tree)
      local normal_wins = 0
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype ~= "neo-tree" and vim.bo[buf].filetype ~= "alpha" then
          normal_wins = normal_wins + 1
        end
      end

      -- Если нет обычных окон, создаем новый буфер
      if normal_wins == 0 then
        vim.cmd("wincmd l")
        vim.cmd("enew")
      end
    end
  end,
})

-- Автоматическое закрытие пустого [No Name] буфера при открытии файла
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    -- Проверяем есть ли пустой [No Name] буфер
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
        local buf_name = vim.api.nvim_buf_get_name(buf)
        local buf_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        
        -- Если буфер пустой и без имени
        if buf_name == "" and #buf_lines == 1 and buf_lines[1] == "" then
          -- Удаляем пустой буфер
          vim.api.nvim_buf_delete(buf, { force = true })
          break
        end
      end
    end
  end,
})
