---@type LazySpec
return {
  "neovim/nvim-lspconfig",
  optional = true,
  ---@type PluginLspOpts
  opts = {
    servers = {
      rust_analyzer = {
        mason = true, -- auto install
        settings = {
          ["rust-analyzer"] = { ---@type _.lspconfig.settings.rust_analyzer.Rust-analyzer|{}
            check = { ---@type _.lspconfig.settings.rust_analyzer.Check|{}
              command = "clippy", -- Use clippy to check the code
            },
          },
        },
      },
    },
  },
}
