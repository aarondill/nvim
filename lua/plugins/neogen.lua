---@type LazySpec
return {
  "danymat/neogen",
  config = true,
  opts = {
    enabled = true,
    snippet_engine = "luasnip",
  },
  keys = {
    {
      "<leader>cg",
      function() require("neogen").generate({ type = "func" }) end,
      desc = "[G]enerate function documentation",
    },
  },
}
