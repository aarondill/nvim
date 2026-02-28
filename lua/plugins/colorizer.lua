local consts = require("consts")
if false then require("colorizer") end -- import for types

local ignored = vim.tbl_map(function(ft) return "!" .. ft end, consts.ignored_filetypes)
---@type LazySpec
return {
  "NvChad/nvim-colorizer.lua",
  cond = vim.o.termguicolors,
  ---@type colorizer.NewOptions
  ---@diagnostic disable: missing-fields
  opts = {
    options = {
      filetypes = { "*", unpack(ignored) },
      parsers = {
        names = { enable = false },
        tailwind = {
          enable = true,
          lsp = true,
          update_names = true,
        },
        hex = {
          enable = true,
          rrggbbaa = true,
          aarrggbb = true,
        },
        css_fn = true,
      },
    },
  },
  ---@diagnostic enable: missing-fields
  event = "LazyFile",
}
