---@type LazySpec
return {
   "m4xshen/hardtime.nvim",
   dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
   opts = {
      disabled_filetypes = require("consts").ignored_filetypes,
      disable_mouse = false,
      restriction_mode = "hint",
      max_time = 100,
      disabled_keys = { ["<Up>"] = {}, ["<Down>"] = {}, ["<Left>"] = {}, ["<Right>"] = {} },
   },
   event = { "BufReadPre", "BufNewFile", "BufEnter" },
   cmd = "Hardtime",
}
