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
---@type LazySpec
return {
  "neovim/nvim-lspconfig",
  optional = true,
  opts = {
    servers = {
      lua_ls = { mason = true }, -- auto install
    },
  },
}
