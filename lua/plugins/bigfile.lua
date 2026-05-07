if false then _ = require("snacks") end
---@type LazySpec
return {
  "folke/snacks.nvim",
  lazy = false,
  priority = 2000,
  ---@type snacks.Config
  opts = {
    bigfile = {},
  },
}
