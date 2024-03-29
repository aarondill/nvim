local create_autocmd = require("utils.create_autocmd")
---@type LazySpec
return {
  "rcarriga/nvim-notify",
  keys = {
    {
      "<leader>un",
      function() require("notify").dismiss({ silent = true, pending = true }) end,
      desc = "Dismiss all Notifications",
    },
  },
  opts = {
    timeout = 3000,
    max_height = function() return math.floor(vim.o.lines * 0.75) end,
    max_width = function() return math.floor(vim.o.columns * 0.75) end,
    on_open = function(win) vim.api.nvim_win_set_config(win, { zindex = 100 }) end,
    stages = "static",
  },
  init = function()
    -- when noice is not enabled, install notify on VeryLazy. if noice is enabled, skip
    if require("lazy.core.config").spec.plugins["noice.nvim"] then return end
    create_autocmd("User", function() vim.notify = require("notify") end, { pattern = "VeryLazy", once = true })
  end,
}
