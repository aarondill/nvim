vim.lsp.config("rust_analyzer", { ---@type vim.lsp.Config
  settings = {
    ["rust-analyzer"] = {
      check = {
        command = "clippy", -- Use clippy to check the code
      },
    },
  },
})

return { ---@type LazySpec
  "williamboman/mason-lspconfig.nvim",
  optional = true,
  opts = { ensure_installed = { "rust_analyzer" } },
}
