local consts = require("consts")
local ignored = vim.tbl_map(function(ft) return "!" .. ft end, consts.ignored_filetypes)
---@type LazySpec
return {
  "NvChad/nvim-colorizer.lua",
  cond = vim.o.termguicolors,
  opts = {
    filetypes = {
      "*",
      unpack(ignored),
    },
    user_default_options = {
      names = false,
      RRGGBBAA = true,
      AARRGGBB = true,
      css_fn = true,
    },
  },
  event = { "BufReadPost", "BufNewFile", "BufWritePre" },
}
