return { ---@type vim.lsp.Config
  settings = {
    ["rust-analyzer"] = {
      checkOnSave = {
        command = "clippy",
      },
      check = {
        command = "clippy", -- Use clippy to check the code
      },
      diagnostics = {
        enable = true,
        experimental = {
          enable = true,
        },
      },
    },
  },
}
