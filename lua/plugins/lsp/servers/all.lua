--- Automatically install servers
---@type LazySpec
return {
  "neovim/nvim-lspconfig",
  optional = true,
  ---@type PluginLspOpts
  opts = {
    servers = {
      bashls = { mason = true },
      jdtls = { mason = true },
      jsonls = { mason = true },
      lua_ls = { mason = true },
      taplo = { mason = true },
      tsserver = { mason = true },
      vimls = { mason = true },
    },
  },
}
