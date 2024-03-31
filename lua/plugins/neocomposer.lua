-- I like. We'll see
---@type LazySpec
return {
  "ecthelionvi/NeoComposer.nvim",
  dependencies = { "kkharji/sqlite.lua" },
  opts = {
    keymaps = {
      play_macro = "Q",
      yank_macro = "yq",
      stop_macro = "cq",
      toggle_record = "q",
      cycle_next = "<c-n>",
      cycle_prev = "<c-p>",
      toggle_macro_menu = "<m-q>",
    },
  },
  keys = function(self)
    local opts = self.opts or {}
    local keymaps = opts.keymaps or {}
    return vim.tbl_values(keymaps)
  end,
  event = { "RecordingEnter" },
  cmd = { "EditMacros", "ToggleDelay", "ClearNeoComposer" },
}
