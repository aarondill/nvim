--- Ensure the cursor is where i expect it to be after escaping
local function esc() return vim.api.nvim_win_get_cursor(0)[2] > 1 and "<esc>l" or "<esc>" end
---@type LazySpec
return {
  "max397574/better-escape.nvim",
  opts = {
    mappings = {
      i = {
        j = { k = esc },
        k = { j = esc },
      },
    },
  },
  event = { "InsertEnter" },
}
