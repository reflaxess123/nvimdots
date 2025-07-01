return {
  -- Цветовые темы
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
  },
  

{
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- иконки
    "MunifTanjim/nui.nvim",        -- UI-компоненты
  },
  config = function()
    local function getTelescopeOpts(state, path)
      return {
        cwd = path,
        search_dirs = { path },
        attach_mappings = function(prompt_bufnr, map)
          local actions = require("telescope.actions")
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local action_state = require("telescope.actions.state")
            local selection = action_state.get_selected_entry()
            local filename = selection.filename
            if (filename == nil) then
              filename = selection[1]
            end
            require("neo-tree.sources.filesystem").navigate(state, state.path, filename)
          end)
          return true
        end
      }
    end

    require("neo-tree").setup({
      filesystem = {
        window = {
          mappings = {
            ["tf"] = "telescope_find",
            ["tg"] = "telescope_grep",
            ["<2-LeftMouse>"] = "open",
            ["<cr>"] = "open_tabnew",
            ["<esc>"] = "cancel",
            ["P"] = { "toggle_preview", config = { use_float = true, use_image_nvim = true } },
          },
        },
        commands = {
          telescope_find = function(state)
            local node = state.tree:get_node()
            local path = node:get_id()
            require('telescope.builtin').find_files(getTelescopeOpts(state, path))
          end,
          telescope_grep = function(state)
            local node = state.tree:get_node()
            local path = node:get_id()
            require('telescope.builtin').live_grep(getTelescopeOpts(state, path))
          end,
        },
      },
    })
  end
},
  -- Telescope
  {
    "nvim-telescope/telescope.nvim", tag = "0.1.6",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local telescope = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", telescope.find_files, { desc = "Fuzzy find files in current directory" })
      vim.keymap.set("n", "<leader>fg", telescope.live_grep, { desc = "Find string in current directory" })
      vim.keymap.set("n", "<leader>fb", telescope.buffers, { desc = "List open buffers" })
      vim.keymap.set("n", "<leader>fh", telescope.help_tags, { desc = "List help tags" })
    end
  },

  -- Treesitter для подсветки
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup {
        ensure_installed = { "lua", "javascript", "typescript", "html", "css", "json", "yaml", "markdown", "python" }, -- Добавь языки, которые используешь
        highlight = {
          enable = true,  -- Включает подсветку синтаксиса на основе Treesitter
          disable = { "latex" }, -- Отключить подсветку для конкретных языков, если нужно
        },
        indent = {
          enable = true, -- Включает умные отступы на основе Treesitter
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<c-space>",
            node_incremental = "<c-space>",
            scope_incremental = "<c-s>",
            node_decremental = "<bs>",
          },
        },
        fold = {
          enable = true,
          fold_contiguous_min_lines = 1, -- Уменьшает минимальное количество строк для сворачивания
          disable = { "typescript" }, -- Отключить сворачивание для конкретных языков
        },
      }
    end
  },

  -- LSP и автодополнение
  "neovim/nvim-lspconfig",
  { "williamboman/mason.nvim" },
  "williamboman/mason-lspconfig.nvim",
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path", "saadparwaiz1/cmp_luasnip", "L3MON4D3/LuaSnip", "hrsh7th/cmp-cmdline" },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      luasnip.config.setup {}

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })

      -- Настройка автодополнения для командной строки (двоеточие)
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          {
            name = "cmdline",
            option = {
              ignore_cmds = { "Man", "!" }
            }
          }
        })
      })

      -- Настройка автодополнения для поиска (слеш)
      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" }
        }
      })

    end,
  },

  -- Подсказка клавиш
  "folke/which-key.nvim",
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "auto",
        globalstatus = true,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "filename", path = 1 }, function()
          local line = vim.fn.line(".")
          local total = vim.fn.line("$")
          return string.format("%d/%d", line, total)
        end },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      inactive_sections = {
        lualine_a = {}, 
        lualine_b = {}, 
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "location" },
        lualine_y = {}, 
        lualine_z = {}
      },
      -- tabline = {
      --   lualine_a = { 'buffers' },
      --   lualine_z = { 'tabs' }
      -- },
      extensions = { "quickfix", "nvim-tree", "lazy" }
    }
  },
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },
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
      on_attach = function(bufnr)
        local gs = require("gitsigns")

        local function map(mode, l, r, opts)
          opts = opts or {}
          vim.keymap.set(mode, l, r, { buffer = bufnr, remap = true, expr = true, silent = true, noremap = true, desc = opts.desc })
        end

        -- Navigation
        map("n", "]c", function() 
          if vim.wo.diff then return "]c" end
          vim.schedule(function() gs.next_hunk() end)
          return ""
        end, { desc = "Next Hunk" })

        map("n", "[c", function() 
          if vim.wo.diff then return "[c" end
          vim.schedule(function() gs.prev_hunk() end)
          return ""
        end, { desc = "Prev Hunk" })

        -- Actions
        map({"n", "v"}, "<leader>hs", ":Gitsigns stage_hunk<CR>", { desc = "Stage Hunk" })
        map({"n", "v"}, "<leader>hr", ":Gitsigns reset_hunk<CR>", { desc = "Reset Hunk" })
        map("n", "<leader>hS", gs.stage_buffer, { desc = "Stage Buffer" })
        map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "Undo Stage Hunk" })
        map("n", "<leader>hR", gs.reset_buffer, { desc = "Reset Buffer" })
        map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview Hunk" })
        map("n", "<leader>hb", function() gs.blame_line{full=true} end, { desc = "Blame Line" })
        map("n", "<leader>hD", gs.diffthis, { desc = "Diff This" })
        map("n", "<leader>hB", function() gs.diffthis("~") end, { desc = "Diff This ~" })
        map("n", "<leader>td", gs.toggle_deleted, { desc = "Toggle Deleted" })
      end
    }
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = { noremap = true, silent = true },
    config = function()
      require("nvim-autopairs").setup {}
    end
  },
  {
    "numToStr/Comment.nvim",
    opts = {},
    lazy = false,
  },
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
  -- Контекст Treesitter
  {
    "nvim-treesitter/nvim-treesitter-context",
    opts = {},
    config = function()
      require("treesitter-context").setup {}
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
  -- Стартовый экран (dashboard)
  {
    "goolord/alpha-nvim",
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      alpha.setup(dashboard.opts)
    end
  },
  -- Автоматическое закрытие/переименование HTML/XML тегов
  {
    "windwp/nvim-ts-autotag",
    opts = {},
    config = function()
      require("nvim-ts-autotag").setup()
    end
  },
  -- Управление окружающими символами (кавычки, скобки и т.д.)
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
  -- Красивый LSP-интерфейс
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
          enable = true,
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
}
