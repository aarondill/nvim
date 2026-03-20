---@type LazySpec
return {
  "chrisgrieser/nvim-origami",
  event = "LazyFile",
  main = "origami",
  opts = {},
  init = function()
    vim.opt.foldlevel = 99
    vim.opt.foldlevelstart = 99
    vim.o.foldcolumn = "0"
  end,
}
