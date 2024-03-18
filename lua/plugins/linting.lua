local mason_ensure_installed = {
  "lua-language-server", -- lua
  "bash-language-server", -- bash
  -- "clangd", -- cpp
  "cspell", -- spelling
  "eslint-lsp", -- eslint
  "eslint_d", -- eslint
  -- "gopls", -- go
  "jdtls", -- java
  "json-lsp", -- json
  "prettier", --prettier
  "shellcheck", --shell
  "taplo", -- toml
  "typescript-language-server", -- Typescript
  "vim-language-server", -- vimscript
  "vint", -- vimscript
  "alex",
  "gitlint",
}
local treesitter_ensure_installed = {
  "dockerfile",
  "git_config",
  "jsdoc",
  "make",
  "toml",
  "vimdoc",
  "java",
}

---@type LazySpec
return {
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      opts = opts or {}
      opts.ensure_installed = vim.list_extend(opts.ensure_installed or {}, treesitter_ensure_installed)
      return opts
    end,
  },
  {
    "williamboman/mason.nvim",
    optional = true,
    opts = function(_, opts)
      opts = opts or {}
      opts.ensure_installed = vim.list_extend(opts.ensure_installed or {}, mason_ensure_installed)
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
