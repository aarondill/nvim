---@type LazySpec
return {
  {
    "neovim/nvim-lspconfig",
    ---@type PluginLspOpts
    opts = {
      servers = {
        tsserver = {
          mason = true, -- auto install
        },
      },
    },
  },
}
