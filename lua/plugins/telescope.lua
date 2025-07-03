return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.6",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local telescope = require("telescope.builtin")
    vim.keymap.set("n", "<leader>ff", telescope.find_files, { desc = "Fuzzy find files in current directory" })
    vim.keymap.set("n", "<leader>fg", telescope.live_grep, { desc = "Find string in current directory" })
    vim.keymap.set("n", "<leader>fb", telescope.buffers, { desc = "List open buffers" })
    vim.keymap.set("n", "<leader>fh", telescope.help_tags, { desc = "List help tags" })
  end
}