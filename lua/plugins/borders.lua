return {
  { "folke/noice.nvim", optional = true, opts = { presets = { lsp_doc_border = true } } },
  {
    "hrsh7th/nvim-cmp",
    optional = true,
    -- Change border of documentation hover window, See https://github.com/neovim/neovim/pull/13998.
    opts = {
      window = { completion = { border = "rounded" }, documentation = { border = "rounded" } },
    },
  },
}
