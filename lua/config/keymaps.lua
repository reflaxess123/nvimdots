vim.keymap.set({"n", "v"}, "y", '"+y')
vim.keymap.set({"n", "v"}, "yy", '"+yy')
vim.keymap.set({"n", "v"}, "d", '"+d')
vim.keymap.set({"n", "v"}, "dd", '"+dd')
vim.keymap.set({"n", "v"}, "p", '"+p')
vim.keymap.set({"n", "v"}, "P", '"+P')

-- Навигация по окнам
vim.keymap.set("n", "<C-Left>",  "<C-w>h")
vim.keymap.set("n", "<C-Down>",  "<C-w>j")
vim.keymap.set("n", "<C-Up>",    "<C-w>k")
vim.keymap.set("n", "<C-Right>", "<C-w>l")

-- Сохранение
vim.keymap.set("n", "<C-s>", ":w<CR>", { desc = "Save file" })
vim.keymap.set("i", "<C-s>", "<Esc>:w<CR>i", { desc = "Save file" })

-- Neo-tree toggle
vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Toggle Neo-tree" })

-- Форматирование вручную
vim.keymap.set("n", "<leader>f", function()
  vim.lsp.buf.format({ async = true })
end, { desc = "Format file" }) 

-- Копирование в системный буфер
local last_time = vim.loop.hrtime()
local speed = 1

local function smart_jump(key)
  local now = vim.loop.hrtime()
  local delta = (now - last_time) / 1e6 -- миллисекунды
  last_time = now

  if delta < 50 then
    speed = math.min(speed + 1, 3)
  else
    speed = 1
  end

  local keys = tostring(speed) .. key
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), 'n', true)
end

-- 3. бинды для всех 4 стрелок
vim.keymap.set("n", "<Down>", function() smart_jump("j") end)
vim.keymap.set("n", "<Up>", function() smart_jump("k") end)
vim.keymap.set("n", "<Left>", function() smart_jump("h") end)
vim.keymap.set("n", "<Right>", function() smart_jump("l") end)

-- Keymaps for splits
vim.keymap.set("n", "<leader>sv", ":split<CR>", { desc = "Split window horizontally" })
vim.keymap.set("n", "<leader>vsv", ":vsplit<CR>", { desc = "Split window vertically" })

-- Navigation between splits
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to down window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to up window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Переключение между буферами
vim.keymap.set("n", "<Tab>", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<S-Tab>", ":bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<leader>b", ":enew<CR>", { desc = "New buffer" })
vim.keymap.set("n", "<C-n>", ":tabnew<CR>", { desc = "New tabpage" })

-- Функция для правильного закрытия буферов
local function close_buffer()
  local buf_count = 0
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
      buf_count = buf_count + 1
    end
  end
  
  if buf_count > 1 then
    vim.cmd("bprevious")
    vim.cmd("bdelete #")
  else
    vim.cmd("enew")
    vim.cmd("bdelete #")
  end
end

vim.keymap.set("n", "<leader>x", close_buffer, { desc = "Close current buffer" })

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostic message" })
