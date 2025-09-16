--- Automatically install servers
return { ---@type LazySpec
  "williamboman/mason-lspconfig.nvim",
  optional = true,
  opts = {
    ensure_installed = {
      "bashls",
      "jdtls",
      "jsonls",
      "lua_ls",
      "taplo",
      "ts_ls",
      "vimls",
      "rust_analyzer",
      -- "tailwindcss",
      "ltex",
    },
  },
}
