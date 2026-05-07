local consts = require("consts")
if false then _ = require("snacks") end
-- Automatically highlights other instances of the word under your cursor.
-- This works with LSP, Treesitter, and regexp matching to find the other
-- instances.
---@type LazySpec
return {
  "folke/snacks.nvim",
  ---@type snacks.Config
  opts = {
    words = {
      filter = function(buf) return not vim.tbl_contains(consts.ignored_filetypes, vim.bo[buf].filetype) end,
    },
  },
  keys = {
    { "]]", function() require("snacks.words").jump(vim.v.count1, true) end, desc = "Next Reference" },
    { "[[", function() require("snacks.words").jump(-vim.v.count1, true) end, desc = "Prev Reference" },
  },
}
