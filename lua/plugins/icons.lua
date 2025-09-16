local icons = require("config.icons")
-- Optional=true to ensure that this file doesn't install any of these
---@type LazySpec
return {
  {
    "folke/flash.nvim",
    optional = true,
    opts = { ---@type Flash.Config
      prompt = {
        prefix = { { icons.flash_prompt, "FlashPromptIcon" } },
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = { options = icons.lualine.options },
    optional = true,
  },
  { "vuki656/package-info.nvim", opts = icons["package-info"], optional = true },
  { "nvim-neo-tree/neo-tree.nvim", opts = icons["neo-tree"], optional = true },
  { "lewis6991/gitsigns.nvim", opts = icons.gitsigns, optional = true },
  { "nvim-telescope/telescope.nvim", opts = icons.telescope, optional = true },
  { "folke/noice.nvim", opts = icons.noice, optional = true },
}
