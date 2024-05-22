-- Show a lightbulb in the gutter when a code action is available
---@type LazySpec
return {
  "gh-liu/nvim-lightbulb", -- A fork to use until kosayoda/nvim-lightbulb#62 is fixed
  -- "kosayoda/nvim-lightbulb",
  event = { "CursorHold", "CursorHoldI" },
  opts = {
    autocmd = { enabled = true },
  },
}
