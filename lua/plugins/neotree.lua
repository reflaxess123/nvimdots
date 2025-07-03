return {
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
      auto_clean_after_session_restore = true,
      enable_refresh_on_write = true,
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = true,
      open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
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
}