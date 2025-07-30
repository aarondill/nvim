local flatten = require("utils.flatten")
---@type LazySpec
return {
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = {
      ensure_installed = { "dockerfile", "git_config", "jsdoc", "make", "toml", "vimdoc", "java" },
    },
  },
  {
    "williamboman/mason.nvim",
    optional = true,
    opts = {
      ensure_installed = { "cspell", "prettier", "shellcheck", "vint", "gitlint" },
    },
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      opts = vim.tbl_deep_extend("keep", opts or {}, {
        linters_by_ft = { markdown = {}, text = {}, gitcommit = {} },
        linters = {},
      })
      table.insert(opts.linters_by_ft.gitcommit, "gitlint")
      return opts
    end,
  },
}
