if false then _ = require("snacks") end
---@type LazySpec
return {
  "folke/snacks.nvim",
  ---@type snacks.Config
  opts = { lazygit = {} },
  keys = {
    { "<leader>gg", function() require("snacks.lazygit").open() end, desc = "Lazygit" },
    { "<leader>gf", function() require("snacks.lazygit").log_file() end, desc = "Lazygit log file" },
  },
}
