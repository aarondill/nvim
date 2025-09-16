return { ---@type vim.lsp.Config
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
}
