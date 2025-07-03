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
}