---@type LazySpec
return {
   "m4xshen/hardtime.nvim",
   dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
   opts = { disabled_filetypes = require("consts").ignored_filetypes },
   event = { "BufReadPre", "BufNewFile", "BufEnter" },
   cmd = "Hardtime",
}
