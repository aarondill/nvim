local is_tty = require("utils.is_tty")
---@type LazySpec
return {
  "sindrets/diffview.nvim",
  keys = {
    { "<leader>fh", "<cmd>DiffviewFileHistory %<cr>", desc = "[F]ile [H]istory" },
    { "<leader>sd", "<cmd>DiffviewOpen<cr>", desc = "[S]how [D]iff" },
  },
  cmd = {
    "DiffviewFileHistory",
    "DiffviewOpen",
    "DiffviewClose",
    "DiffviewToggleFiles",
    "DiffviewFocusFiles",
    "DiffviewRefresh",
  },
  opts = {
    use_icons = not is_tty(),
  },
}
