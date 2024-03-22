local is_tty = require("utils.is_tty")
return {
  "otavioschwanck/arrow.nvim",
  opts = {
    show_icons = not is_tty(),
    leader_key = ";", -- Recommended to be a single key
    save_key = "git_root",
  },
  keys = function(self) return { self.opts and self.opts.leader_key or ";", mode = "n" } end,
}
