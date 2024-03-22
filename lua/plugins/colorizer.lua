---@type LazySpec
return {
  "NvChad/nvim-colorizer.lua",
  cond = vim.o.termguicolors,
  opts = {
    user_default_options = {
      names = false,
      RRGGBBAA = true,
      AARRGGBB = true,
      css_fn = true,
    },
  },
  event = { "BufReadPost", "BufNewFile", "BufWritePre" },
}
