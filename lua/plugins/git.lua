return {
  -- Git конфликты
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    config = function()
      require('git-conflict').setup({
        default_mappings = true,
        default_commands = true,
        disable_diagnostics = false,
        list_opener = 'copen',
        highlights = {
          incoming = 'DiffAdd',
          current = 'DiffText',
        }
      })

      vim.keymap.set('n', '<leader>co', '<Plug>(git-conflict-ours)', { desc = 'Accept current change' })
      vim.keymap.set('n', '<leader>ct', '<Plug>(git-conflict-theirs)', { desc = 'Accept incoming change' })
      vim.keymap.set('n', '<leader>cb', '<Plug>(git-conflict-both)', { desc = 'Accept both changes' })
      vim.keymap.set('n', '<leader>c0', '<Plug>(git-conflict-none)', { desc = 'Accept none' })
      vim.keymap.set('n', '<leader>cn', '<Plug>(git-conflict-next-conflict)', { desc = 'Next conflict' })
      vim.keymap.set('n', '<leader>cp', '<Plug>(git-conflict-prev-conflict)', { desc = 'Previous conflict' })
    end,
  },

  -- Улучшенный diff viewer (первая копия)
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("diffview").setup({
        diff_binaries = false,
        enhanced_diff_hl = true,
        git_cmd = { "git" },
        use_icons = true,
        show_help_hints = true,
        watch_index = true,
        icons = {
          folder_closed = "",
          folder_open = "",
        },
        signs = {
          fold_closed = "",
          fold_open = "",
          done = "✓",
        },
        view = {
          default = {
            layout = "diff2_horizontal",
            winbar_info = false,
          },
          merge_tool = {
            layout = "diff3_horizontal",
            disable_diagnostics = true,
            winbar_info = true,
          },
          file_history = {
            layout = "diff2_horizontal",
            winbar_info = false,
          },
        },
        keymaps = {
          disable_defaults = false,
          view = {
            { "n", "<tab>",      "<Cmd>DiffviewToggleFiles<CR>",          { desc = "Toggle file panel" } },
            { "n", "gf",         "<Cmd>DiffviewToggleFiles<CR>",          { desc = "Toggle file panel" } },
            { "n", "<leader>co", "<Cmd>DiffviewConflictChooseOurs<CR>",   { desc = "Choose ours" } },
            { "n", "<leader>ct", "<Cmd>DiffviewConflictChooseTheirs<CR>", { desc = "Choose theirs" } },
            { "n", "<leader>cb", "<Cmd>DiffviewConflictChooseBoth<CR>",   { desc = "Choose both" } },
            { "n", "<leader>cn", "<Cmd>DiffviewConflictChooseNone<CR>",   { desc = "Choose none" } },
            { "n", "dx",         "<Cmd>DiffviewConflictChooseNone<CR>",   { desc = "Delete conflict" } },
          },
        },
      })
    end,
  },

  -- Git linker
  {
    "linrongbin16/gitlinker.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("gitlinker").setup()
    end,
  },

  -- Расширенный gitsigns с полной конфигурацией
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      -- Устанавливаем яркие цвета для git изменений
      vim.api.nvim_set_hl(0, 'GitSignsAdd', { fg = '#9ece6a', ctermfg = 107 })
      vim.api.nvim_set_hl(0, 'GitSignsChange', { fg = '#e0af68', ctermfg = 179 })
      vim.api.nvim_set_hl(0, 'GitSignsDelete', { fg = '#f7768e', ctermfg = 203 })

      require('gitsigns').setup({
        signs = {
          add          = { text = '+' },
          change       = { text = '~' },
          delete       = { text = '_' },
          topdelete    = { text = '‾' },
          changedelete = { text = '~' },
          untracked    = { text = '┆' },
        },
        signcolumn = true,
        numhl = false,
        linehl = false,
        word_diff = false,
        attach_to_untracked = true,
        current_line_blame = false,

        on_attach = function(bufnr)
          local gs = require('gitsigns')

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Навигация между hunks
          map('n', ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
          end, { expr = true, desc = "Next hunk" })

          map('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
          end, { expr = true, desc = "Previous hunk" })

          -- Actions
          map('n', '<leader>hs', gs.stage_hunk, { desc = "Stage hunk" })
          map('n', '<leader>hr', gs.reset_hunk, { desc = "Reset hunk" })
          map('n', '<leader>hS', gs.stage_buffer, { desc = "Stage buffer" })
          map('n', '<leader>hu', gs.undo_stage_hunk, { desc = "Undo stage hunk" })
          map('n', '<leader>hR', gs.reset_buffer, { desc = "Reset buffer" })
          map('n', '<leader>hp', function()
            gs.preview_hunk_inline()
          end, { desc = "Preview hunk inline" })
          map('n', '<leader>hP', gs.preview_hunk, { desc = "Preview hunk in popup" })
          map('n', '<leader>hb', function() gs.blame_line { full = true } end, { desc = "Blame line" })
          map('n', '<leader>hB', gs.toggle_current_line_blame, { desc = "Toggle line blame" })
          map('n', '<leader>hd', gs.diffthis, { desc = "Diff this" })
          map('n', '<leader>hD', function() gs.diffthis('~') end, { desc = "Diff this ~" })
          map('n', '<leader>td', gs.toggle_deleted, { desc = "Toggle deleted" })
        end
      })

      -- Git команды
      vim.keymap.set("n", "<leader>gs", function()
        require('telescope.builtin').git_status()
      end, { desc = "Git Status" })

      -- Настройка which-key для git команд
      local ok, wk = pcall(require, "which-key")
      if ok then
        wk.add({
          { "<leader>g", group = "🔀 Git" },
          { "<leader>gI", desc = "Toggle inline highlighting" },
          { "<leader>gn", desc = "Next change" },
          { "<leader>gp", desc = "Previous change" },
          { "<leader>gs", desc = "Git Status" },
          { "<leader>h", group = "🔧 Hunks" },
          { "<leader>ha", desc = "Accept hunk" },
          { "<leader>hx", desc = "Reject hunk" },
          { "<leader>hp", desc = "Preview hunk inline" },
          { "<leader>hP", desc = "Preview hunk popup" },
          { "<leader>hs", desc = "Stage hunk" },
          { "<leader>hr", desc = "Reset hunk" },
          { "<leader>hw", desc = "Toggle word diff" },
          { "<leader>hb", desc = "Blame line" },
          { "<leader>hB", desc = "Toggle line blame" },
        })
      end
    end,
  },
}