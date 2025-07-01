local conform = require("conform")

conform.setup({
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "ruff_format" },
    javascript = { "prettierd" },
    javascriptreact = { "prettierd" },
    typescript = { "prettierd" },
    typescriptreact = { "prettierd" },
    html = { "prettierd" },
    json = { "prettierd" },
    yaml = { "prettierd" },
    css = { "prettierd" },
  },
  formatters = {
    prettierd = {
      prepend_args = { "--tab-width", "2" },
    },
    stylua = {
      prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" },
    },
  },
})
