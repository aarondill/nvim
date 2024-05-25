local root = require("utils.root")
local current = 2
---@type LazySpec
return {
  "CRAG666/betterTerm.nvim",
  opts = {},
  keys = {
    -- toggle firts term
    {
      "<C-'>",
      function() require("betterTerm").open() end,
      mode = { "n", "t" },
      desc = "Open terminal",
    },
    -- Override the C-CR mapping too (ideally would open in root)
    -- https://github.com/CRAG666/betterTerm.nvim/issues/12
    {
      "<C-CR>",
      function() require("betterTerm").open(nil, { cwd = root.get() }) end,
      mode = { "n", "t" },
      "Terminal (root dir)",
    },
    -- Select term focus
    { "<leader>tt", function() require("betterTerm").select() end, desc = "Select terminal" },
    -- Create new term
    {
      "<leader>tn",
      function()
        require("betterTerm").open(current)
        current = current + 1
      end,
      desc = "New terminal",
    },
  },
}
