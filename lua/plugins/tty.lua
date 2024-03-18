local is_tty = require("utils.is_tty")
-- Don't change anything if not in a tty
if not is_tty() then return {} end

return {
  { "nvim-tree/nvim-web-devicons", optional = true, cond = false }, -- Disable it
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        icons_enabled = false,
        theme = "seoul256",
      },
    }, -- a more reasonable default theme in a dark tty
    optional = true,
  },
  {
    "nvimdev/dashboard-nvim",
    optional = true,
    opts = function(_, opts)
      for _, v in ipairs(opts.config.center) do
        v.icon = nil -- No icons
      end
    end,
  },
}
