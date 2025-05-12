--- Automatically install servers
---@type LazySpec
return {
  "neovim/nvim-lspconfig",
  optional = true,
  opts = {
    servers = { --- TODO: Better way to do this?
      bashls = { mason = true },
      jdtls = { mason = true },
      jsonls = { mason = true },
      lua_ls = { mason = true },
      taplo = { mason = true },
      ts_ls = { mason = true },
      vimls = { mason = true },
    },
  },
}
