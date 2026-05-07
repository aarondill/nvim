if false then _ = require("snacks") end
---@type LazySpec
return {
  "folke/snacks.nvim",
  ---@type snacks.Config
  opts = {
    bufremove = {},
  },
  keys = {
    { "<leader>bd", function() require("snacks.bufdelete").delete() end, desc = "Delete Buffer" },
    {
      "<leader>bD",
      function() require("snacks.bufdelete").delete({ force = true }) end,
      desc = "Delete Buffer (Force)",
    },
  },
}
