---@type LazySpec
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      tsserver = {
        settings = { ---@type lspconfig.settings.tsserver|{}
          completions = {
            completeFunctionCalls = true,
          },
        },
      },
    },
  },
}
