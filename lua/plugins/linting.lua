---@type LazySpec
return {
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      opts = opts or {}
      opts.ensure_installed = vim.list_extend(opts.ensure_installed or {}, {
        "dockerfile",
        "git_config",
        "jsdoc",
        "make",
        "toml",
        "vimdoc",
        "java",
      })
      return opts
    end,
  },
  {
    "williamboman/mason.nvim",
    optional = true,
    opts = function(_, opts)
      opts = opts or {}
      opts.ensure_installed = vim.list_extend(opts.ensure_installed or {}, {
        "alex",
        "gitlint",
      })
      return opts
    end,
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      opts = vim.tbl_deep_extend("keep", opts or {}, {
        linters = {},
        linters_by_ft = { markdown = {}, text = {}, gitcommit = {} },
      })
      table.insert(opts.linters_by_ft.markdown, "alex")
      table.insert(opts.linters_by_ft.text, "alex")
      table.insert(opts.linters_by_ft.gitcommit, "gitlint")
      return opts
    end,
  },
}
