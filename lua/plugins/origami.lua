---@type LazySpec
return {
  "chrisgrieser/nvim-origami",
  event = "LazyFile",
  main = "origami",
  opts = {
    foldtext = {
      disableOnFt = require("consts").ignored_filetypes,
    },
    autoFold = {
      enabled = true,
      kinds = { "imports" }, ---@type lsp.FoldingRangeKind[]
    },
  },
  init = function()
    vim.opt.foldlevel = 99
    vim.opt.foldlevelstart = 99
    vim.o.foldcolumn = "0"
  end,
}
