return { ---@type vim.lsp.Config
  settings = {
    ["rust-analyzer"] = {
      check = {
        command = "clippy", -- Use clippy to check the code
      },
    },
  },
}
