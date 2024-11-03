-- Show a lightbulb in the gutter when a code action is available
---@type LazySpec
return {
  "kosayoda/nvim-lightbulb",
  event = { "CursorHold", "CursorHoldI" },
  opts = {
    autocmd = { enabled = true },
  },
}
