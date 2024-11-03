---@type LazySpec
return {
  "mawkler/modicator.nvim",
  init = function()
    -- These are required for Modicator to work
    vim.o.cursorline, vim.o.number, vim.o.termguicolors = true, true, true
  end,
  event = { "ModeChanged", "LazyFile" },
  opts = {},
}
