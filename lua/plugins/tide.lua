---@type LazySpec
return {
  "jackMort/tide.nvim",
  opts = {
    keys = {
      leader = ";",
    },
    animation_duration = 100, -- Animation duration in milliseconds
  },
  keys = function(self) return { (self.opts and self.opts.keys and self.opts.keys.leader) or ";" } end,
  dependencies = {
    "MunifTanjim/nui.nvim",
    -- "nvim-tree/nvim-web-devicons",
    --Webdevicons is replaced by mini.icons
    "nvim-mini/mini.icons",
  },
}
