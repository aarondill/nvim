local flatten = require("utils.flatten")
local mason_ensure_installed = flatten({
  { "cspell", "eslint-lsp", "eslint_d", "prettier" },
  { "shellcheck", "vint", "alex", "gitlint" },
})
local treesitter_ensure_installed = { "dockerfile", "git_config", "jsdoc", "make", "toml", "vimdoc", "java" }

---@type LazySpec
return {
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      opts = vim.tbl_deep_extend("keep", opts or {}, { ensure_installed = {} })
      vim.list_extend(opts.ensure_installed, treesitter_ensure_installed)
      return opts
    end,
  },
  {
    "williamboman/mason.nvim",
    optional = true,
    opts = function(_, opts)
      opts = vim.tbl_deep_extend("keep", opts or {}, { ensure_installed = {} })
      vim.list_extend(opts.ensure_installed, mason_ensure_installed)
      return opts
    end,
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      opts = vim.tbl_deep_extend("keep", opts or {}, {
        linters_by_ft = { markdown = {}, text = {}, gitcommit = {} },
        linters = {},
      })
      table.insert(opts.linters_by_ft.markdown, "alex")
      table.insert(opts.linters_by_ft.text, "alex")
      table.insert(opts.linters_by_ft.gitcommit, "gitlint")
      return opts
    end,
  },
}
