vim.lsp.config("rust_analyzer", { ---@type vim.lsp.Config
  settings = {
    ["rust-analyzer"] = {
      check = {
        command = "clippy", -- Use clippy to check the code
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
      rust_analyzer = { mason = true }, -- auto install
    },
  },
}
