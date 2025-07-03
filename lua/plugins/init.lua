return {
  -- Цветовые темы
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    keys = {
      { "<leader>e", ":Neotree toggle<CR>", desc = "Toggle Neo-tree" },
    },
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
        close_if_last_window = false,
        enable_refresh_on_write = true,
        popup_border_style = "rounded",
        enable_git_status = true,
        enable_diagnostics = true,
        open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline", "neo-tree" },
        retain_hidden_root_indent = false,
        default_component_configs = {
          container = {
            enable_character_fade = true
          },
          indent = {
            indent_size = 2,
            padding = 1,
            with_markers = true,
            indent_marker = "│",
            last_indent_marker = "└",
            highlight = "NeoTreeIndentMarker",
            with_expanders = nil,
            expander_collapsed = "",
            expander_expanded = "",
            expander_highlight = "NeoTreeExpander",
          },
          modified = {
            symbol = "[+]",
            highlight = "NeoTreeModified",
          },
          name = {
            trailing_slash = false,
            use_git_status_colors = true,
            highlight = "NeoTreeFileName",
          },
          git_status = {
            symbols = {
              added     = "",
              modified  = "",
              deleted   = "✖",
              renamed   = "󰁕",
              untracked = "",
              ignored   = "",
              unstaged  = "󰄱",
              staged    = "",
              conflict  = "",
            }
          },
        },
        window = {
          position = "left",
          width = 30,
          mapping_options = {
            noremap = true,
            nowait = true,
          },
          mappings = {
            ["<space>"] = {
              "toggle_node",
              nowait = false,
            },
            ["<2-LeftMouse>"] = "open",
            ["<cr>"] = "open",
            ["<esc>"] = "cancel",
            ["<esc><esc>"] = function() vim.cmd("qa!") end,
            ["P"] = { "toggle_preview", config = { use_float = true, use_image_nvim = true } },
            ["l"] = "focus_preview",
            ["S"] = "open_split",
            ["s"] = "open_vsplit",
            ["t"] = "open_tabnew",
            ["w"] = "open_with_window_picker",
            ["C"] = "close_node",
            ["z"] = "close_all_nodes",
            ["a"] = {
              "add",
              config = {
                show_path = "none"
              }
            },
            ["A"] = "add_directory",
            ["d"] = "delete",
            ["r"] = "rename",
            ["y"] = "copy_path_to_clipboard",
            ["x"] = "cut_to_clipboard",
            ["p"] = "paste_from_clipboard",
            ["c"] = "copy",
            ["m"] = "move",
            ["q"] = "close_window",
            ["R"] = "refresh",
            ["?"] = "show_help",
            ["<"] = "prev_source",
            [">"] = "next_source",
            ["i"] = "show_file_details",
          }
        },
        nesting_rules = {},
        filesystem = {
          filtered_items = {
            visible = false,
            hide_dotfiles = true,
            hide_gitignored = true,
            hide_hidden = true,
            hide_by_name = {
              "node_modules"
            },
            hide_by_pattern = {
              "*.meta",
              "*/src/*/tsconfig.json",
            },
            always_show = {
              ".gitignored"
            },
            never_show = {
              ".DS_Store",
              "thumbs.db"
            },
            never_show_by_pattern = {
              ".null-ls_*",
            },
          },
          follow_current_file = {
            enabled = false,
            leave_dirs_open = false,
          },
          group_empty_dirs = false,
          hijack_netrw_behavior = "open_default",
          use_libuv_file_watcher = false,
          window = {
            mappings = {
              ["<bs>"] = "navigate_up",
              ["."] = "set_root",
              ["H"] = "toggle_hidden",
              ["/"] = "fuzzy_finder",
              ["D"] = "fuzzy_finder_directory",
              ["#"] = "fuzzy_sorter",
              ["f"] = "filter_on_submit",
              ["<c-x>"] = "clear_filter",
              ["[g"] = "prev_git_modified",
              ["]g"] = "next_git_modified",
              ["tf"] = "telescope_find",
              ["tg"] = "telescope_grep",
              ["Y"] = "copy_path_to_clipboard",
              ["<C-y>"] = "copy_paths_to_clipboard",
            },
            fuzzy_finder_mappings = {
              ["<down>"] = "move_cursor_down",
              ["<C-n>"] = "move_cursor_down",
              ["<up>"] = "move_cursor_up",
              ["<C-p>"] = "move_cursor_up",
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
            copy_path_to_clipboard = function(state)
              local node = state.tree:get_node()
              local path = node:get_id()
              vim.fn.setreg('+', path)
              vim.notify("Path copied to clipboard: " .. path)
            end,
            copy_paths_to_clipboard = function(state)
              local tree = state.tree
              local selected_paths = {}

              -- Получаем выделенные узлы через renderer
              local renderer = require("neo-tree.ui.renderer")
              local manager = require("neo-tree.sources.manager")
              local events = require("neo-tree.events")

              -- Пытаемся получить выделенные узлы из состояния
              if state.explicitly_opened_directories then
                for node_id, _ in pairs(state.explicitly_opened_directories) do
                  table.insert(selected_paths, node_id)
                end
              end

              -- Если ничего не выделено, берем текущий узел
              if #selected_paths == 0 then
                local current_node = tree:get_node()
                if current_node then
                  table.insert(selected_paths, current_node:get_id())
                end
              end

              if #selected_paths > 0 then
                local paths_text = table.concat(selected_paths, "\n")
                vim.fn.setreg('+', paths_text)
                vim.notify("Paths copied to clipboard (" .. #selected_paths .. " files)")
              else
                vim.notify("No files to copy")
              end
            end,
          }
        },
        buffers = {
          follow_current_file = {
            enabled = true,
            leave_dirs_open = false,
          },
          group_empty_dirs = true,
          show_unloaded = true,
          window = {
            mappings = {
              ["bd"] = "buffer_delete",
              ["<bs>"] = "navigate_up",
              ["."] = "set_root",
            }
          },
        },
        git_status = {
          window = {
            position = "float",
            mappings = {
              ["A"]  = "git_add_all",
              ["gu"] = "git_unstage_file",
              ["ga"] = "git_add_file",
              ["gr"] = "git_revert_file",
              ["gc"] = "git_commit",
              ["gp"] = "git_push",
              ["gg"] = "git_commit_and_push",
            }
          }
        }
      })
    end
  },
  -- Telescope
  {
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
  },

  -- Treesitter для подсветки
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup {
        ensure_installed = { "lua", "javascript", "typescript", "html", "css", "json", "yaml", "markdown", "python" }, -- Добавь языки, которые используешь
        highlight = {
          enable = true,                                                                                               -- Включает подсветку синтаксиса на основе Treesitter
          disable = { "latex" },                                                                                       -- Отключить подсветку для конкретных языков, если нужно
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
          disable = { "typescript" },    -- Отключить сворачивание для конкретных языков
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
        theme = require('config.lualine_transparent'),
        globalstatus = true,
        component_separators = { left = "⏽", right = "⏽" },
        section_separators = { left = "■", right = "■" },
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
        lualine_z = { "location", function()
          return os.date("%d.%m.%Y %H:%M")
        end },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {}
      },
      tabline = {
        lualine_a = {
          {
            'buffers',
            show_filename_only = true,
            hide_filename_extension = false,
            show_modified_status = true,
            mode = 0,
            max_length = vim.o.columns * 2 / 3,
            filetype_names = {
              TelescopePrompt = 'Telescope',
              dashboard = 'Dashboard',
              packer = 'Packer',
              fzf = 'FZF',
              alpha = 'Alpha',
              neo_tree = 'Neo-tree'
            },
            buffers_color = {
              active = { fg = '#c0caf5', bg = 'NONE' },
              inactive = { fg = '#565f89', bg = 'NONE' },
            },
            symbols = {
              modified = ' ●',
              alternate_file = '',
              directory = '',
            },
            section_separators = { left = '', right = '' },
            component_separators = { left = '', right = '' },
          }
        },
        lualine_z = { 'tabs' }
      },
      extensions = { "quickfix", "nvim-tree", "lazy" }
    }
  },
  {
    "nvim-tree/nvim-web-devicons",
    config = function()
      require('nvim-web-devicons').setup {
        default = true,
      }
    end
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
      current_line_blame = false,
      linehl = false,
      on_attach = function(bufnr)
        local gs = require("gitsigns")

        local function map(mode, l, r, opts)
          opts = opts or {}
          vim.keymap.set(mode, l, r,
            { buffer = bufnr, remap = true, expr = true, silent = true, noremap = true, desc = opts.desc })
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
        map({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<CR>", { desc = "Stage Hunk" })
        map({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<CR>", { desc = "Reset Hunk" })
        map("n", "<leader>hS", gs.stage_buffer, { desc = "Stage Buffer" })
        map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "Undo Stage Hunk" })
        map("n", "<leader>hR", gs.reset_buffer, { desc = "Reset Buffer" })
        map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview Hunk" })
        map("n", "<leader>hb", function() gs.blame_line { full = true } end, { desc = "Blame Line" })
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
  -- Подсветка цветов
  {
    "catgoose/nvim-colorizer.lua",
    opts = "",
    config = function()
      require("colorizer").setup()
    end
  },
  -- Стартовый экран (dashboard) - отключен из-за ошибок
  -- {
  --   "goolord/alpha-nvim",
  --   event = "VimEnter",
  --   config = function()
  --     -- конфигурация закомментирована
  --   end
  -- },
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
  -- Красивые уведомления
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

      -- Горячая клавиша для истории уведомлений
      vim.keymap.set("n", "<leader>nh", ":Notifications<CR>", { desc = "Show notification history" })
    end,
  },
  -- Миниатюра кода (мини-карта)
  {
    "gorbit99/codewindow.nvim",
    config = function()
      local codewindow = require("codewindow")
      codewindow.setup({
        auto_enable = false,
        minimap_width = 20,
        width_multiplier = 4,
        use_lsp = true,
        use_treesitter = true,
        use_git = true,
      })
      vim.keymap.set("n", "<leader>m", codewindow.toggle_minimap, { desc = "Toggle minimap" })
    end,
  },
  -- Плавная прокрутка
  {
    "karb94/neoscroll.nvim",
    config = function()
      require("neoscroll").setup({
        mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "<C-y>", "<C-e>", "zt", "zz", "zb" },
        hide_cursor = true,
        stop_eof = true,
        respect_scrolloff = false,
        cursor_scrolls_alone = true,
        easing_function = nil,
        pre_hook = nil,
        post_hook = nil,
        performance_mode = false,
      })
    end,
  },
  -- Плавающий терминал
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        size = 20,
        open_mapping = [[<c-\>]],
        hide_numbers = true,
        shade_filetypes = {},
        shade_terminals = true,
        shading_factor = 2,
        start_in_insert = true,
        insert_mappings = true,
        persist_size = true,
        direction = "float",
        close_on_exit = true,
        shell = "pwsh",
        float_opts = {
          border = "curved",
          winblend = 0,
          highlights = {
            border = "Normal",
            background = "Normal",
          },
        },
      })

      -- Горячие клавиши
      local Terminal = require("toggleterm.terminal").Terminal

      -- Горизонтальный терминал
      vim.keymap.set("n", "<leader>th", ":ToggleTerm direction=horizontal<CR>", { desc = "Horizontal terminal" })

      -- Вертикальный терминал
      vim.keymap.set("n", "<leader>tv", ":ToggleTerm direction=vertical size=80<CR>", { desc = "Vertical terminal" })

      -- Плавающий терминал
      vim.keymap.set("n", "<leader>tf", ":ToggleTerm direction=float<CR>", { desc = "Float terminal" })

      -- Несколько плавающих терминалов
      vim.keymap.set("n", "<leader>t1", ":1ToggleTerm direction=float<CR>", { desc = "Float terminal 1" })
      vim.keymap.set("n", "<leader>t2", ":2ToggleTerm direction=float<CR>", { desc = "Float terminal 2" })
      vim.keymap.set("n", "<leader>t3", ":3ToggleTerm direction=float<CR>", { desc = "Float terminal 3" })

      -- Lazygit (если установлен)
      local lazygit = Terminal:new({
        cmd = "lazygit",
        dir = "git_dir",
        direction = "float",
        float_opts = {
          border = "double",
        },
        on_open = function(term)
          vim.cmd("startinsert!")
          vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
        end,
        on_close = function(term)
          vim.cmd("startinsert!")
        end,
      })

      vim.keymap.set("n", "<leader>tg", function() lazygit:toggle() end, { desc = "Lazygit" })

      -- Настройка клавиш в терминале
      function _G.set_terminal_keymaps()
        local opts = { buffer = 0 }
        vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
        vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
        vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
        vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
        vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
        vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
      end

      vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
    end,
  },
  -- Outline символов (навигация по функциям/классам)
  {
    "simrat39/symbols-outline.nvim",
    config = function()
      require("symbols-outline").setup({
        highlight_hovered_item = true,
        show_guides = true,
        auto_preview = false,
        position = 'right',
        relative_width = true,
        width = 25,
        auto_close = false,
        show_numbers = false,
        show_relative_numbers = false,
        show_symbol_details = true,
        preview_bg_highlight = 'Pmenu',
        autofold_depth = nil,
        auto_unfold_hover = true,
        fold_markers = { '', '' },
        wrap = false,
        keymaps = {
          close = { "<Esc>", "q" },
          goto_location = "<Cr>",
          focus_location = "o",
          hover_symbol = "<C-space>",
          toggle_preview = "K",
          rename_symbol = "r",
          code_actions = "a",
          fold = "h",
          unfold = "l",
          fold_all = "W",
          unfold_all = "E",
          fold_reset = "R",
        },
        lsp_blacklist = {},
        symbol_blacklist = {},
        symbols = {
          File = { icon = "", hl = "@text.uri" },
          Module = { icon = "", hl = "@namespace" },
          Namespace = { icon = "", hl = "@namespace" },
          Package = { icon = "", hl = "@namespace" },
          Class = { icon = "𝓒", hl = "@type" },
          Method = { icon = "ƒ", hl = "@method" },
          Property = { icon = "", hl = "@method" },
          Field = { icon = "", hl = "@field" },
          Constructor = { icon = "", hl = "@constructor" },
          Enum = { icon = "ℰ", hl = "@type" },
          Interface = { icon = "ﰮ", hl = "@type" },
          Function = { icon = "", hl = "@function" },
          Variable = { icon = "", hl = "@constant" },
          Constant = { icon = "", hl = "@constant" },
          String = { icon = "𝓐", hl = "@string" },
          Number = { icon = "#", hl = "@number" },
          Boolean = { icon = "⊨", hl = "@boolean" },
          Array = { icon = "", hl = "@constant" },
          Object = { icon = "⦿", hl = "@type" },
          Key = { icon = "🔐", hl = "@type" },
          Null = { icon = "NULL", hl = "@type" },
          EnumMember = { icon = "", hl = "@field" },
          Struct = { icon = "𝓢", hl = "@type" },
          Event = { icon = "🗲", hl = "@type" },
          Operator = { icon = "+", hl = "@operator" },
          TypeParameter = { icon = "𝙏", hl = "@parameter" },
          Component = { icon = "", hl = "@function" },
          Fragment = { icon = "", hl = "@constant" },
        },
      })

      -- Горячие клавиши
      vim.keymap.set("n", "<leader>o", ":SymbolsOutline<CR>", { desc = "Toggle symbols outline" })
      vim.keymap.set("n", "<leader>so", ":SymbolsOutlineOpen<CR>", { desc = "Open symbols outline" })
      vim.keymap.set("n", "<leader>sc", ":SymbolsOutlineClose<CR>", { desc = "Close symbols outline" })
    end,
  },
  -- Уведомления об изменениях файлов
  {
    "nvim-lua/plenary.nvim", -- используем plenary для автокоманд
    config = function()
      -- Настройка автокоманд для отслеживания изменений
      -- Уведомление при сохранении файла
      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = "*",
        callback = function()
          local filename = vim.fn.expand("%:t")
          local filepath = vim.fn.expand("%:p")

          -- Игнорируем временные файлы и системные папки
          local ignored_patterns = {
            "%.git/",
            "node_modules/",
            "%.tmp$",
            "%.swp$",
            "%.log$",
            "nvim%-data",
          }

          for _, pattern in ipairs(ignored_patterns) do
            if string.match(filepath, pattern) then
              return
            end
          end

          vim.notify(
            string.format("📝 Файл сохранен: %s", filename),
            vim.log.levels.INFO,
            {
              title = "File Changed",
              timeout = 2000,
            }
          )
        end,
      })

      -- Уведомление при создании нового файла
      vim.api.nvim_create_autocmd("BufNewFile", {
        pattern = "*",
        callback = function()
          local filename = vim.fn.expand("%:t")
          if filename ~= "" then
            vim.notify(
              string.format("✨ Новый файл: %s", filename),
              vim.log.levels.INFO,
              {
                title = "New File",
                timeout = 2000,
              }
            )
          end
        end,
      })

      -- Уведомление при удалении файла (через Neovim)
      vim.api.nvim_create_autocmd("BufDelete", {
        pattern = "*",
        callback = function()
          local filename = vim.fn.expand("%:t")
          if filename ~= "" and not string.match(filename, "^term://") then
            vim.notify(
              string.format("🗑️  Файл закрыт: %s", filename),
              vim.log.levels.WARN,
              {
                title = "File Closed",
                timeout = 1500,
              }
            )
          end
        end,
      })

      -- Отслеживание изменений файлов извне (например, от агентов)
      vim.api.nvim_create_autocmd("FocusGained", {
        pattern = "*",
        callback = function()
          vim.cmd("checktime") -- Проверить изменения файлов
        end,
      })

      vim.api.nvim_create_autocmd("FileChangedShellPost", {
        pattern = "*",
        callback = function()
          local filename = vim.fn.expand("%:t")
          vim.notify(
            string.format("⚠️  Файл изменен извне: %s", filename),
            vim.log.levels.WARN,
            {
              title = "External Change",
              timeout = 3000,
            }
          )
        end,
      })

      -- Настройка для автоматической перезагрузки
      vim.opt.autoread = true
    end,
  },
  -- Git конфликты и diff acceptor
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

      -- Горячие клавиши для работы с конфликтами
      vim.keymap.set('n', '<leader>co', '<Plug>(git-conflict-ours)', { desc = 'Accept current change' })
      vim.keymap.set('n', '<leader>ct', '<Plug>(git-conflict-theirs)', { desc = 'Accept incoming change' })
      vim.keymap.set('n', '<leader>cb', '<Plug>(git-conflict-both)', { desc = 'Accept both changes' })
      vim.keymap.set('n', '<leader>c0', '<Plug>(git-conflict-none)', { desc = 'Accept none' })
      vim.keymap.set('n', '<leader>cn', '<Plug>(git-conflict-next-conflict)', { desc = 'Next conflict' })
      vim.keymap.set('n', '<leader>cp', '<Plug>(git-conflict-prev-conflict)', { desc = 'Previous conflict' })
    end,
  },
  -- Улучшенный diff viewer
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
        file_panel = {
          listing_style = "tree",
          tree_options = {
            flatten_dirs = true,
            folder_statuses = "only_folded",
          },
          win_config = {
            position = "left",
            width = 35,
            win_opts = {}
          },
        },
        file_history_panel = {
          log_options = {
            git = {
              single_file = {
                diff_merges = "combined",
              },
              multi_file = {
                diff_merges = "first-parent",
              },
            },
          },
          win_config = {
            position = "bottom",
            height = 16,
            win_opts = {}
          },
        },
        commit_log_panel = {
          win_config = {
            win_opts = {},
          }
        },
        default_args = {
          DiffviewOpen = {},
          DiffviewFileHistory = {},
        },
        hooks = {},
        keymaps = {
          disable_defaults = false,
          view = {
            { "n", "<tab>",      "<Cmd>DiffviewToggleFiles<CR>",          { desc = "Toggle file panel" } },
            { "n", "gf",         "<Cmd>DiffviewToggleFiles<CR>",          { desc = "Toggle file panel" } },
            { "n", "<leader>e",  "<Cmd>DiffviewToggleFiles<CR>",          { desc = "Toggle file panel" } },
            { "n", "<leader>co", "<Cmd>DiffviewConflictChooseOurs<CR>",   { desc = "Choose ours" } },
            { "n", "<leader>ct", "<Cmd>DiffviewConflictChooseTheirs<CR>", { desc = "Choose theirs" } },
            { "n", "<leader>cb", "<Cmd>DiffviewConflictChooseBoth<CR>",   { desc = "Choose both" } },
            { "n", "<leader>cn", "<Cmd>DiffviewConflictChooseNone<CR>",   { desc = "Choose none" } },
            { "n", "dx",         "<Cmd>DiffviewConflictChooseNone<CR>",   { desc = "Delete conflict" } },
          },
          diff1 = {
            { "n", "g?", "<Cmd>h diffview-maps-diff1<CR>", { desc = "Open help" } },
          },
          diff2 = {
            { "n", "g?", "<Cmd>h diffview-maps-diff2<CR>", { desc = "Open help" } },
          },
          diff3 = {
            { "n", "g?",         "<Cmd>h diffview-maps-diff3<CR>",        { desc = "Open help" } },
            { "n", "<leader>co", "<Cmd>DiffviewConflictChooseOurs<CR>",   { desc = "Choose ours (local)" } },
            { "n", "<leader>cm", "<Cmd>DiffviewConflictChooseBase<CR>",   { desc = "Choose base" } },
            { "n", "<leader>ct", "<Cmd>DiffviewConflictChooseTheirs<CR>", { desc = "Choose theirs (remote)" } },
          },
          diff4 = {
            { "n", "g?",         "<Cmd>h diffview-maps-diff4<CR>",        { desc = "Open help" } },
            { "n", "<leader>co", "<Cmd>DiffviewConflictChooseOurs<CR>",   { desc = "Choose ours (local)" } },
            { "n", "<leader>cm", "<Cmd>DiffviewConflictChooseBase<CR>",   { desc = "Choose base" } },
            { "n", "<leader>ct", "<Cmd>DiffviewConflictChooseTheirs<CR>", { desc = "Choose theirs (remote)" } },
            { "n", "<leader>ca", "<Cmd>DiffviewConflictChooseAll<CR>",    { desc = "Choose all" } },
            { "n", "dx",         "<Cmd>DiffviewConflictChooseNone<CR>",   { desc = "Delete conflict" } },
          },
          file_panel = {
            { "n", "j",             "<Cmd>lua require'diffview.actions'.next_entry()<CR>",          { desc = "Next entry" } },
            { "n", "<down>",        "<Cmd>lua require'diffview.actions'.next_entry()<CR>",          { desc = "Next entry" } },
            { "n", "k",             "<Cmd>lua require'diffview.actions'.prev_entry()<CR>",          { desc = "Previous entry" } },
            { "n", "<up>",          "<Cmd>lua require'diffview.actions'.prev_entry()<CR>",          { desc = "Previous entry" } },
            { "n", "<cr>",          "<Cmd>lua require'diffview.actions'.select_entry()<CR>",        { desc = "Open diff" } },
            { "n", "o",             "<Cmd>lua require'diffview.actions'.select_entry()<CR>",        { desc = "Open diff" } },
            { "n", "l",             "<Cmd>lua require'diffview.actions'.select_entry()<CR>",        { desc = "Open diff" } },
            { "n", "<2-LeftMouse>", "<Cmd>lua require'diffview.actions'.select_entry()<CR>",        { desc = "Open diff" } },
            { "n", "-",             "<Cmd>lua require'diffview.actions'.toggle_stage_entry()<CR>",  { desc = "Stage/unstage" } },
            { "n", "S",             "<Cmd>lua require'diffview.actions'.stage_all()<CR>",           { desc = "Stage all" } },
            { "n", "U",             "<Cmd>lua require'diffview.actions'.unstage_all()<CR>",         { desc = "Unstage all" } },
            { "n", "X",             "<Cmd>lua require'diffview.actions'.restore_entry()<CR>",       { desc = "Restore entry" } },
            { "n", "L",             "<Cmd>lua require'diffview.actions'.open_commit_log()<CR>",     { desc = "Open commit log" } },
            { "n", "zo",            "<Cmd>lua require'diffview.actions'.open_fold()<CR>",           { desc = "Expand fold" } },
            { "n", "h",             "<Cmd>lua require'diffview.actions'.close_fold()<CR>",          { desc = "Close fold" } },
            { "n", "zc",            "<Cmd>lua require'diffview.actions'.close_fold()<CR>",          { desc = "Close fold" } },
            { "n", "za",            "<Cmd>lua require'diffview.actions'.toggle_fold()<CR>",         { desc = "Toggle fold" } },
            { "n", "zR",            "<Cmd>lua require'diffview.actions'.open_all_folds()<CR>",      { desc = "Expand all folds" } },
            { "n", "zM",            "<Cmd>lua require'diffview.actions'.close_all_folds()<CR>",     { desc = "Close all folds" } },
            { "n", "<c-b>",         "<Cmd>lua require'diffview.actions'.scroll_view(-0.25)<CR>",    { desc = "Scroll up" } },
            { "n", "<c-f>",         "<Cmd>lua require'diffview.actions'.scroll_view(0.25)<CR>",     { desc = "Scroll down" } },
            { "n", "<tab>",         "<Cmd>lua require'diffview.actions'.select_next_entry()<CR>",   { desc = "Next entry" } },
            { "n", "<s-tab>",       "<Cmd>lua require'diffview.actions'.select_prev_entry()<CR>",   { desc = "Previous entry" } },
            { "n", "gf",            "<Cmd>lua require'diffview.actions'.goto_file_edit()<CR>",      { desc = "Go to file" } },
            { "n", "<C-w><C-f>",    "<Cmd>lua require'diffview.actions'.goto_file_split()<CR>",     { desc = "Go to file in split" } },
            { "n", "<C-w>gf",       "<Cmd>lua require'diffview.actions'.goto_file_tab()<CR>",       { desc = "Go to file in tab" } },
            { "n", "i",             "<Cmd>lua require'diffview.actions'.listing_style()<CR>",       { desc = "Toggle listing style" } },
            { "n", "f",             "<Cmd>lua require'diffview.actions'.toggle_flatten_dirs()<CR>", { desc = "Toggle flatten dirs" } },
            { "n", "R",             "<Cmd>lua require'diffview.actions'.refresh_files()<CR>",       { desc = "Refresh" } },
            { "n", "<leader>e",     "<Cmd>lua require'diffview.actions'.focus_files()<CR>",         { desc = "Focus files" } },
            { "n", "<leader>b",     "<Cmd>lua require'diffview.actions'.toggle_files()<CR>",        { desc = "Toggle files" } },
            { "n", "g<C-x>",        "<Cmd>lua require'diffview.actions'.cycle_layout()<CR>",        { desc = "Cycle layout" } },
            { "n", "[x",            "<Cmd>lua require'diffview.actions'.prev_conflict()<CR>",       { desc = "Previous conflict" } },
            { "n", "]x",            "<Cmd>lua require'diffview.actions'.next_conflict()<CR>",       { desc = "Next conflict" } },
            { "n", "g?",            "<Cmd>lua require'diffview.actions'.help('file_panel')<CR>",    { desc = "Open help" } },
          },
          file_history_panel = {
            { "n", "g!",            "<Cmd>lua require'diffview.actions'.options()<CR>",                  { desc = "Open options" } },
            { "n", "<C-A-d>",       "<Cmd>lua require'diffview.actions'.open_in_diffview()<CR>",         { desc = "Open in diffview" } },
            { "n", "y",             "<Cmd>lua require'diffview.actions'.copy_hash()<CR>",                { desc = "Copy hash" } },
            { "n", "L",             "<Cmd>lua require'diffview.actions'.open_commit_log()<CR>",          { desc = "Show commit details" } },
            { "n", "zR",            "<Cmd>lua require'diffview.actions'.open_all_folds()<CR>",           { desc = "Expand all folds" } },
            { "n", "zM",            "<Cmd>lua require'diffview.actions'.close_all_folds()<CR>",          { desc = "Close all folds" } },
            { "n", "j",             "<Cmd>lua require'diffview.actions'.next_entry()<CR>",               { desc = "Next entry" } },
            { "n", "<down>",        "<Cmd>lua require'diffview.actions'.next_entry()<CR>",               { desc = "Next entry" } },
            { "n", "k",             "<Cmd>lua require'diffview.actions'.prev_entry()<CR>",               { desc = "Previous entry" } },
            { "n", "<up>",          "<Cmd>lua require'diffview.actions'.prev_entry()<CR>",               { desc = "Previous entry" } },
            { "n", "<cr>",          "<Cmd>lua require'diffview.actions'.select_entry()<CR>",             { desc = "Open diff" } },
            { "n", "o",             "<Cmd>lua require'diffview.actions'.select_entry()<CR>",             { desc = "Open diff" } },
            { "n", "<2-LeftMouse>", "<Cmd>lua require'diffview.actions'.select_entry()<CR>",             { desc = "Open diff" } },
            { "n", "<c-b>",         "<Cmd>lua require'diffview.actions'.scroll_view(-0.25)<CR>",         { desc = "Scroll up" } },
            { "n", "<c-f>",         "<Cmd>lua require'diffview.actions'.scroll_view(0.25)<CR>",          { desc = "Scroll down" } },
            { "n", "<tab>",         "<Cmd>lua require'diffview.actions'.select_next_entry()<CR>",        { desc = "Next entry" } },
            { "n", "<s-tab>",       "<Cmd>lua require'diffview.actions'.select_prev_entry()<CR>",        { desc = "Previous entry" } },
            { "n", "gf",            "<Cmd>lua require'diffview.actions'.goto_file_edit()<CR>",           { desc = "Go to file" } },
            { "n", "<C-w><C-f>",    "<Cmd>lua require'diffview.actions'.goto_file_split()<CR>",          { desc = "Go to file in split" } },
            { "n", "<C-w>gf",       "<Cmd>lua require'diffview.actions'.goto_file_tab()<CR>",            { desc = "Go to file in tab" } },
            { "n", "<leader>e",     "<Cmd>lua require'diffview.actions'.focus_files()<CR>",              { desc = "Focus files" } },
            { "n", "<leader>b",     "<Cmd>lua require'diffview.actions'.toggle_files()<CR>",             { desc = "Toggle files" } },
            { "n", "g<C-x>",        "<Cmd>lua require'diffview.actions'.cycle_layout()<CR>",             { desc = "Cycle layout" } },
            { "n", "g?",            "<Cmd>lua require'diffview.actions'.help('file_history_panel')<CR>", { desc = "Open help" } },
          },
          option_panel = {
            { "n", "<tab>", "<Cmd>lua require'diffview.actions'.select_entry()<CR>",       { desc = "Change option" } },
            { "n", "q",     "<Cmd>lua require'diffview.actions'.close()<CR>",              { desc = "Close" } },
            { "n", "g?",    "<Cmd>lua require'diffview.actions'.help('option_panel')<CR>", { desc = "Open help" } },
          },
          help_panel = {
            { "n", "q",     "<Cmd>lua require'diffview.actions'.close()<CR>", { desc = "Close help" } },
            { "n", "<esc>", "<Cmd>lua require'diffview.actions'.close()<CR>", { desc = "Close help" } },
          },
        },
      })
    end,
  },
  -- Inline diff viewer как в Cursor
  {
    "linrongbin16/gitlinker.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("gitlinker").setup()
    end,
  },
  -- Улучшенный inline diff
  {
    "sindrets/diffview.nvim",
    config = function()
      -- Дополнительная настройка для inline режима
      vim.keymap.set("n", "<leader>gi", function()
        -- Переключение в inline режим diff
        vim.cmd("windo diffthis")
        vim.notify("🔄 Inline diff mode activated", vim.log.levels.INFO, { title = "Inline Diff" })
      end, { desc = "Toggle inline diff" })

      vim.keymap.set("n", "<leader>gx", function()
        -- Выключение inline режима
        vim.cmd("windo diffoff")
        vim.notify("❌ Inline diff mode disabled", vim.log.levels.INFO, { title = "Inline Diff" })
      end, { desc = "Exit inline diff" })
    end,
  },
  -- Inline hunks viewer
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      -- Устанавливаем яркие цвета по умолчанию для unstaged изменений
      vim.api.nvim_set_hl(0, 'GitSignsAdd', { fg = '#9ece6a', ctermfg = 107 })    -- Зеленый для unstaged
      vim.api.nvim_set_hl(0, 'GitSignsChange', { fg = '#e0af68', ctermfg = 179 }) -- Желтый для unstaged
      vim.api.nvim_set_hl(0, 'GitSignsDelete', { fg = '#f7768e', ctermfg = 203 }) -- Красный для unstaged

      -- Яркие фоны для строк
      vim.api.nvim_set_hl(0, 'GitSignsAddLn', { bg = '#2d5a2d', fg = 'NONE' })
      vim.api.nvim_set_hl(0, 'GitSignsChangeLn', { bg = '#5a5a2d', fg = 'NONE' })
      vim.api.nvim_set_hl(0, 'GitSignsDeleteLn', { bg = '#5a2d2d', fg = 'NONE' })

      -- Яркие inline цвета
      vim.api.nvim_set_hl(0, 'GitSignsAddInline', { bg = '#3d7a3d', fg = 'NONE' })
      vim.api.nvim_set_hl(0, 'GitSignsChangeInline', { bg = '#7a7a3d', fg = 'NONE' })
      vim.api.nvim_set_hl(0, 'GitSignsDeleteInline', { bg = '#7a3d3d', fg = 'NONE' })

      require('gitsigns').setup({
        signs = {
          add          = { text = '+' },
          change       = { text = '~' },
          delete       = { text = '_' },
          topdelete    = { text = '‾' },
          changedelete = { text = '~' },
          untracked    = { text = '┆' },
        },
        signcolumn = true, -- Включить колонку знаков
        numhl = false,
        linehl = false,
        word_diff = false,
        base = nil, -- Сравнивать с HEAD (по умолчанию)
        diff_opts = {
          algorithm = 'minimal',
          internal = false,
          indent_heuristic = true,
          vertical = false,
        },
        watch_gitdir = {
          interval = 1000,
          follow_files = true
        },
        attach_to_untracked = true,
        current_line_blame = false,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = 'eol',
          delay = 1000,
          ignore_whitespace = false,
        },
        current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil,
        max_file_length = 40000,
        preview_config = {
          border = 'single',
          style = 'minimal',
          relative = 'cursor',
          row = 0,
          col = 1
        },

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

          -- Inline diff actions
          map('n', '<leader>hs', gs.stage_hunk, { desc = "Stage hunk" })
          map('n', '<leader>hr', gs.reset_hunk, { desc = "Reset hunk" })
          map('v', '<leader>hs', function() gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end,
            { desc = "Stage selected hunk" })
          map('v', '<leader>hr', function() gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end,
            { desc = "Reset selected hunk" })
          map('n', '<leader>hS', gs.stage_buffer, { desc = "Stage buffer" })
          map('n', '<leader>hu', gs.undo_stage_hunk, { desc = "Undo stage hunk" })
          map('n', '<leader>hR', gs.reset_buffer, { desc = "Reset buffer" })

          -- Inline preview как в Cursor
          map('n', '<leader>hp', function()
            gs.preview_hunk_inline()
          end, { desc = "Preview hunk inline" })

          map('n', '<leader>hP', gs.preview_hunk, { desc = "Preview hunk in popup" })

          -- Blame line
          map('n', '<leader>hb', function() gs.blame_line { full = true } end, { desc = "Blame line" })
          map('n', '<leader>hB', gs.toggle_current_line_blame, { desc = "Toggle line blame" })

          -- Diff this
          map('n', '<leader>hd', gs.diffthis, { desc = "Diff this" })
          map('n', '<leader>hD', function() gs.diffthis('~') end, { desc = "Diff this ~" })

          -- Toggle deleted
          map('n', '<leader>td', gs.toggle_deleted, { desc = "Toggle deleted" })

          -- Toggle word diff (как в Cursor)
          map('n', '<leader>hw', function()
            require('gitsigns').toggle_word_diff()
            vim.notify("🔤 Word diff toggled", vim.log.levels.INFO, { title = "Git" })
          end, { desc = "Toggle word diff" })

          -- Show inline changes for current line
          map('n', '<leader>hl', function()
            gs.show()
          end, { desc = "Show line changes" })

          -- Принять/отклонить изменения как в Cursor
          map('n', '<leader>ha', function()
            gs.stage_hunk()
            -- Обновляем gitsigns чтобы убрать зеленую подсветку
            vim.defer_fn(function()
              gs.refresh()
            end, 100)
            vim.notify("✅ Изменение принято", vim.log.levels.INFO, { title = "Git" })
          end, { desc = "Accept hunk" })

          map('n', '<leader>hx', function()
            gs.reset_hunk()
            vim.notify("❌ Изменение отклонено", vim.log.levels.WARN, { title = "Git" })
          end, { desc = "Reject hunk" })

          -- Text object
          map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = "Select hunk" })
        end
      })

      -- Настройка ярких цветов для inline diff
      vim.api.nvim_set_hl(0, 'GitSignsAddLn', { bg = '#2d5a2d', fg = 'NONE' })        -- Ярче зеленый фон
      vim.api.nvim_set_hl(0, 'GitSignsChangeLn', { bg = '#5a5a2d', fg = 'NONE' })     -- Ярче желтый фон
      vim.api.nvim_set_hl(0, 'GitSignsDeleteLn', { bg = '#5a2d2d', fg = 'NONE' })     -- Ярче красный фон
      vim.api.nvim_set_hl(0, 'GitSignsAddInline', { bg = '#3d7a3d', fg = 'NONE' })    -- Очень яркий зеленый для слов
      vim.api.nvim_set_hl(0, 'GitSignsChangeInline', { bg = '#7a7a3d', fg = 'NONE' }) -- Очень яркий желтый для слов
      vim.api.nvim_set_hl(0, 'GitSignsDeleteInline', { bg = '#7a3d3d', fg = 'NONE' }) -- Очень яркий красный для слов

      -- Дополнительные яркие цвета для Telescope git diff
      vim.api.nvim_set_hl(0, 'DiffAdd', { bg = '#2d5a2d', fg = '#90EE90' })               -- Яркий зеленый для добавлений
      vim.api.nvim_set_hl(0, 'DiffDelete', { bg = '#5a2d2d', fg = '#FF6B6B' })            -- Яркий красный для удалений
      vim.api.nvim_set_hl(0, 'DiffChange', { bg = '#5a5a2d', fg = '#FFD93D' })            -- Яркий желтый для изменений
      vim.api.nvim_set_hl(0, 'DiffText', { bg = '#7a7a3d', fg = '#FFFFFF', bold = true }) -- Белый текст на ярком фоне

      -- Команда для показа всех изменений inline
      vim.keymap.set("n", "<leader>gI", function()
        local gitsigns = require('gitsigns')
        -- Включить line highlighting для всех изменений
        vim.cmd("Gitsigns toggle_linehl")
        vim.cmd("Gitsigns toggle_word_diff")
        vim.notify("🎨 Inline highlighting enabled", vim.log.levels.INFO, { title = "Git Inline" })
      end, { desc = "Toggle inline highlighting" })

      -- Навигация по всем изменениям в проекте
      vim.keymap.set("n", "<leader>gn", function()
        require('gitsigns').next_hunk()
      end, { desc = "Next change" })

      vim.keymap.set("n", "<leader>gp", function()
        require('gitsigns').prev_hunk()
      end, { desc = "Previous change" })

      -- Простое Git Status окно в Telescope
      vim.keymap.set("n", "<leader>gs", function()
        require('telescope.builtin').git_status()
      end, { desc = "Git Status" })

      -- Настройка which-key для git команд
      local ok, wk = pcall(require, "which-key")
      if ok then
        wk.register({
          g = {
            name = "🔀 Git",
            I = { "Toggle inline highlighting" },
            n = { "Next change" },
            p = { "Previous change" },
            s = { "Git Status" },
          },
          h = {
            name = "🔧 Hunks",
            a = { "Accept hunk" },
            x = { "Reject hunk" },
            p = { "Preview hunk inline" },
            P = { "Preview hunk popup" },
            s = { "Stage hunk" },
            r = { "Reset hunk" },
            w = { "Toggle word diff" },
            b = { "Blame line" },
            B = { "Toggle line blame" },
          }
        }, { prefix = "<leader>" })
      end
    end,
  },
}
