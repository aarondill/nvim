---@type LazySpec
return {
  "Wansmer/treesj",
  keys = {
    { "<leader>m", function() require("treesj").toggle() end, desc = "Toggle TreeSJ" },
    { "<leader>jj", function() require("treesj").join() end, desc = "Join TreeSJ" },
    { "<leader>js", function() require("treesj").split() end, desc = "Split TreeSJ" },
  },
  opts = { use_default_keymaps = false, max_join_length = 200 },
}
