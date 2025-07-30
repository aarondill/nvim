---This file is to set the opts_extend for various plugins, this has to happen before the seeting is set, to ensure that nothing is overwritten

---@type LazySpec
return {
  {
    "williamboman/mason-lspconfig.nvim",
    optional = true,
    opts_extend = { "ensure_installed", "automatic_enable.exclude" },
    opts = { ensure_installed = {}, automatic_enable = { exclude = {} } },
  },
  {
    "williamboman/mason.nvim",
    optional = true,
    opts_extend = { "ensure_installed" },
    opts = { ensure_installed = {} },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts_extend = { "ensure_installed" },
    opts = { ensure_installed = {} },
  },
}
