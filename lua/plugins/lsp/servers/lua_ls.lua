---@type LazySpec
return {
  "neovim/nvim-lspconfig",
  optional = true,
  ---@type PluginLspOpts
  opts = {
    servers = {
      lua_ls = {
        mason = true, -- auto install
        settings = {
          Lua = { ---@type _.lspconfig.settings.lua_ls.Lua|{}
            workspace = { checkThirdParty = false }, ---@type _.lspconfig.settings.lua_ls.Workspace | {}
            codeLens = { enable = true },
            completion = { ---@type _.lspconfig.settings.lua_ls.Completion | {}
              postfix = "@", -- use @ to fix a mistake (default)
              callSnippet = "Disable",
            },
          },
        },
      },
    },
  },
}
