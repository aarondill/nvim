---@type LazySpec
return {
  { "ConradIrwin/vim-bracketed-paste", event = "VimEnter" }, -- Bracketed paste to escape charecters
  { "rhysd/conflict-marker.vim", event = "LazyFile" }, -- detect git conflict markers
  { "NMAC427/guess-indent.nvim", event = "LazyFile", opts = {} }, -- Guess the current file indention type
  { "wsdjeg/vim-fetch", event = { "BufNewFile", "VimEnter" } }, -- Allow line numbers in file names
  { "micarmst/vim-spellsync", event = "LazyFile" }, -- Rebuild spell files on file open
  { "nvim-tree/nvim-web-devicons", lazy = true }, -- icons
  { "dstein64/vim-startuptime", cmd = "StartupTime", init = function() vim.g.startuptime_tries = 10 end }, -- measure startuptime
  { "nvim-lua/plenary.nvim", lazy = true }, -- library used by other plugins

  -- Session management. This saves your session in the background,
  -- keeping track of open buffers, window arrangement, and more.
  -- You can restore sessions when returning through the dashboard.
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = { options = vim.opt.sessionoptions:get() },
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore Session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
      { "<leader>qd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
    },
  },
}
