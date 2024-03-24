---@type LazySpec
return {
  "max397574/better-escape.nvim",
  opts = {
    mapping = { "jk", "kj" },
    --- Ensure the cursor is where i expect it to be after escaping
    keys = function() return vim.api.nvim_win_get_cursor(0)[2] > 1 and "<esc>l" or "<esc>" end,
  },
  event = { "InsertEnter" },
}
