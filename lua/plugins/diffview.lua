local close = { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close the diffview" } }
---@type LazySpec
return {
  "sindrets/diffview.nvim",
  -- hello
  keys = {
    { "<leader>fh", "<cmd>DiffviewFileHistory %<cr>", desc = "[F]ile [H]istory" },
    { "<leader>ss", "<cmd>DiffviewOpen<cr>", desc = "[S]how [S]tatus" },
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
    use_icons = not require("utils").is_tty(),
    keymaps = {
      file_panel = { close },
      view = { close },
      file_history_panel = { close },
    },
  },
}
