vim.lsp.config("lua_ls", { ---@type vim.lsp.Config
  settings = {
    Lua = {
      workspace = { checkThirdParty = false },
      codeLens = { enable = true },
      completion = {
        postfix = "@", -- use @ to fix a mistake (default)
        callSnippet = "Disable",
      },
    },
  },
})
return { ---@type LazySpec
  "williamboman/mason-lspconfig.nvim",
  optional = true,
  opts = { ensure_installed = { "lua_ls" } },
}
