if false then _ = require("snacks") end
---@type LazySpec
return {
  "folke/snacks.nvim",
  init = function()
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.ui.input = function(...)
      require("snacks.input") -- Lazy load snacks.input
      return vim.ui.input(...)
    end
  end,
  ---@type snacks.Config
  opts = {
    input = {},
  },
}
