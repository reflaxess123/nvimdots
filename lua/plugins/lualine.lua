return {
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
          mode = 2,
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
}