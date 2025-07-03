return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup {
      ensure_installed = { "lua", "javascript", "typescript", "html", "css", "json", "yaml", "markdown", "python" },
      highlight = {
        enable = true,
        disable = { "latex" },
      },
      indent = {
        enable = true,
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
        fold_contiguous_min_lines = 1,
        disable = { "typescript" },
      },
    }
  end
}