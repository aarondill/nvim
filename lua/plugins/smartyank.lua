---@type LazySpec
return {
  "ibhagwan/smartyank.nvim",
  opts = { highlight = { timeout = 1000 } },
  event = "LazyFile",
  init = function()
    vim.opt.clipboard = "" -- Set clipboard to '' to stop copying to system clipboard on yank
  end,
}
