-- Show a lightbulb in the gutter when a code action is available
---@type LazySpec
return {
  -- "kosayoda/nvim-lightbulb",
  "Traap/nvim-lightbulb", -- a fork until PR #67 is merged
  event = { "CursorHold", "CursorHoldI" },
  opts = {
    autocmd = { enabled = true },
  },
}
