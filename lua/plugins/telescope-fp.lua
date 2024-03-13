-- View telescope pickers and chose one to run (mapped to <leader>t)
---@type LazySpec
return {
  "keyvchan/telescope-find-pickers.nvim",
  dependencies = "nvim-telescope/telescope.nvim",
  config = function() require("telescope").load_extension("find_pickers") end,
  keys = {
    {
      "<leader>t",
      function() return require("telescope").extensions.find_pickers.find_pickers() end,
      desc = "Find Telescope pickers",
    },
  },
}
