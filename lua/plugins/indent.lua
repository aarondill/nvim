if false then _ = require("snacks") end
---@type LazySpec
return {
  "folke/snacks.nvim",
  event = "LazyFile",
  ---@type snacks.Config
  opts = {
    indent = {
      filter = function(buf) return not vim.tbl_contains(require("consts").ignored_filetypes, vim.bo[buf].filetype) end,
    },
  },
}
