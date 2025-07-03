return {
  -- Подсказка клавиш
  {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup({
        preset = "modern",
      })
    end,
  },

  -- Иконки
  {
    "nvim-tree/nvim-web-devicons",
    config = function()
      require('nvim-web-devicons').setup {
        default = true,
      }
    end
  },

  -- Git интеграция
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "-" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
      current_line_blame = false,
      linehl = false,
    }
  },

  -- Автопары скобок
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = { noremap = true, silent = true },
    config = function()
      require("nvim-autopairs").setup {}
    end
  },

  -- Комментарии
  {
    "numToStr/Comment.nvim",
    opts = {},
    lazy = false,
  },

  -- Форматирование
  {
    "stevearc/conform.nvim",
    lazy = false,
    opts = {},
  },

  -- Полоски отступов
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {},
    config = function()
      require("ibl").setup {
        indent = {
          char = "│",
          tab_char = "│",
        },
        scope = { enabled = false },
      }
    end
  },

  -- Подсветка цветов
  {
    "catgoose/nvim-colorizer.lua",
    opts = "",
    config = function()
      require("colorizer").setup()
    end
  },

  -- Автозакрытие HTML тегов
  {
    "windwp/nvim-ts-autotag",
    opts = {},
    config = function()
      require("nvim-ts-autotag").setup()
    end
  },

  -- Окружающие символы
  {
    "echasnovski/mini.nvim",
    version = "*",
    config = function()
      require("mini.surround").setup()
    end,
  },

  -- Цветные скобки
  {
    "HiPhish/rainbow-delimiters.nvim",
    config = function()
      local rainbow_delimiters = require('rainbow-delimiters')
      vim.g.rainbow_delimiters = {
        strategy = {
          [''] = rainbow_delimiters.strategy['global'],
          vim = rainbow_delimiters.strategy['local'],
        },
        query = {
          [''] = 'rainbow-delimiters',
          lua = 'rainbow-blocks',
        },
        highlight = {
          'RainbowDelimiterRed',
          'RainbowDelimiterYellow',
          'RainbowDelimiterBlue',
          'RainbowDelimiterOrange',
          'RainbowDelimiterGreen',
          'RainbowDelimiterViolet',
          'RainbowDelimiterCyan',
        },
      }
    end
  },

  -- LSP интерфейс
  {
    "nvimdev/lspsaga.nvim",
    event = "LspAttach",
    config = function()
      require('lspsaga').setup({
        ui = {
          border = 'rounded',
          code_action = '💡',
        },
        lightbulb = {
          enable = false,
          sign = true,
          virtual_text = true,
        },
      })
    end,
    dependencies = {
      { "nvim-tree/nvim-web-devicons" },
      { "nvim-treesitter/nvim-treesitter" }
    }
  },

  -- Уведомления
  {
    "rcarriga/nvim-notify",
    opts = {
      background_colour = "#000000",
      render = "compact",
      timeout = 3000,
    },
    config = function(_, opts)
      require("notify").setup(opts)
      vim.notify = require("notify")
      vim.keymap.set("n", "<leader>nh", ":Notifications<CR>", { desc = "Show notification history" })
    end,
  },

  -- Подсказки для навигации
  {
    "tris203/precognition.nvim",
    event = "VeryLazy",
    opts = {
      startVisible = true,
      showBlankVirtLine = false,
      highlightColor = { link = "Comment" },
      hints = {
        w = { text = "w", prio = 10 },
        b = { text = "b", prio = 9 },
        e = { text = "e", prio = 8 },
        ["0"] = { text = "0", prio = 1 },
        ["$"] = { text = "$", prio = 1 },
        MatchingPair = { text = "%", prio = 5 },
      },
      gutterHints = {
        gg = { text = "gg", prio = 9 },
        G = { text = "G", prio = 10 },
      },
      disabled_fts = { "startify", "NvimTree" },
    },
    cmd = { "Precognition", "PrecognitionPeek" },
  },

  -- Hydra для режимов
  {
    "nvimtools/hydra.nvim",
    config = function()
      local Hydra = require("hydra")
      
      -- Hydra для изменения размера окон
      Hydra({
        name = "Resize",
        mode = "n",
        body = "<C-w>",
        heads = {
          { "<Left>", "<C-w>3<", { nowait = true } },
          { "<Right>", "<C-w>3>", { nowait = true } },
          { "<Up>", "<C-w>2+", { nowait = true } },
          { "<Down>", "<C-w>2-", { nowait = true } },
          { "=", "<C-w>=", { nowait = true } },
          { "q", nil, { exit = true } },
        }
      })
      
      -- Hydra для Git
      Hydra({
        name = "Git",
        mode = "n",
        body = "<leader>g",
        heads = {
          { "s", ":Gitsigns stage_hunk<CR>", { desc = "Stage hunk" } },
          { "u", ":Gitsigns undo_stage_hunk<CR>", { desc = "Undo stage" } },
          { "r", ":Gitsigns reset_hunk<CR>", { desc = "Reset hunk" } },
          { "p", ":Gitsigns preview_hunk<CR>", { desc = "Preview hunk" } },
          { "b", ":Gitsigns blame_line<CR>", { desc = "Blame line" } },
          { "n", ":Gitsigns next_hunk<CR>", { desc = "Next hunk" } },
          { "N", ":Gitsigns prev_hunk<CR>", { desc = "Prev hunk" } },
          { "q", nil, { exit = true } },
        }
      })
      
      -- Hydra для показа всех движений
      Hydra({
        name = "Movement Guide",
        mode = "n",
        body = "<leader>?",
        hint = [[
 ╭─────────────────── MOVEMENT GUIDE ──────────────────────╮
 │                                                         │
 │  Basic Movement:           Word Movement:               │
 │  h ← j ↓ k ↑ l →          w → next word start          │
 │  0 → line start           e → next word end            │
 │  $ → line end             b ← prev word start          │
 │  ^ → first non-blank      ge← prev word end            │
 │                                                         │
 │  Line Movement:           Screen Movement:              │
 │  gg → file start          H → screen top               │
 │  G → file end             M → screen middle            │
 │  :n → goto line n         L → screen bottom            │
 │  % → matching bracket     Ctrl-u → half page up        │
 │                           Ctrl-d → half page down      │
 │  Search Movement:         Jump Movement:               │
 │  /text → search forward   Ctrl-o → prev position       │
 │  ?text → search backward  Ctrl-i → next position       │
 │  n → next match           `` → last position           │
 │  N → prev match           '. → last change             │
 │                                                         │
 │  Text Objects:            Counts:                      │
 │  f{char} → find char      5j → move 5 lines down       │
 │  t{char} → till char      3w → move 3 words forward    │
 │  ; → repeat f/t           2dd → delete 2 lines         │
 │  , → reverse f/t          10G → goto line 10           │
 │                                                         │
 │                     [q] quit                            │
 ╰─────────────────────────────────────────────────────────╯
]],
        heads = {
          { "q", nil, { exit = true, desc = "quit" } },
          { "<Esc>", nil, { exit = true, desc = "quit" } },
        },
        config = {
          color = "pink",
          invoke_on_body = true,
          hint = {
            position = "top-right",
            float_opts = {
              border = "rounded",
              row = 2,
              col = vim.o.columns - 60
            }
          }
        }
      })
    end,
  },
}