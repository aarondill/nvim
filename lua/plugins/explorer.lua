if false then _ = require("snacks") end
return {
  "folke/snacks.nvim",
  ---@type snacks.Config
  opts = {
    explorer = {},
    picker = { sources = { explorer = {} } },
  },
  keys = {
    { "<leader>ee", function() require("snacks.explorer").open() end, desc = "Toggle Explorer" },
  },
}
