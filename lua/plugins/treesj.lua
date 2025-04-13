---@type LazySpec
return {
  "Wansmer/treesj",
  keys = {
    { "<leader>m", function() require("treesj").toggle() end },
    { "<leader>jj", function() require("treesj").join() end },
    { "<leader>js", function() require("treesj").split() end },
  },
  opts = { use_default_keymaps = false, max_join_length = 200 },
}
