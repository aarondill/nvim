if false then _ = require("snacks") end
---@type LazySpec
return {
  "folke/snacks.nvim",
  opts = {
    terminal = {},
  },
  keys = {
    { "<C-'>", function() require("snacks.terminal").toggle() end, mode = { "n", "t" }, desc = "Toggle terminal" },
    {
      "<C-CR>",
      function() require("snacks.terminal").toggle(nil, { cwd = require("utils.root").get() }) end,
      mode = { "n", "t" },
      desc = "Terminal (root dir)",
    },
    { "<leader>tn", function() require("snacks.terminal").open() end, desc = "New Terminal" },
  },
}
