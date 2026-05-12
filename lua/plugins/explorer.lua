if false then _ = require("snacks") end
return {
  "folke/snacks.nvim",
  ---@type snacks.Config
  opts = {
    explorer = {},
    picker = {
      hidden = true,
      sources = {
        explorer = {
          win = {
            list = {
              keys = {
                ["o"] = "confirm", -- overwrite 'o' to open the file in editor
              },
            },
          },
        },
      },
    },
  },
  keys = {
    { "<leader>ee", function() require("snacks.explorer").open() end, desc = "Toggle Explorer" },
  },
}
