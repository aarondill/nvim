---@type LazySpec
return {
  "mbbill/undotree",
  keys = {
    { "<leader>uu", "<Cmd>UndotreeToggle<Cr>", desc = "Toggle Undotree" },
  },
  init = function()
    vim.g.undotree_WindowLayout = 2 -- put the window on the left, and the diff across the bottom
    vim.g.undotree_SetFocusWhenToggle = 1 -- Focus the tree!
    vim.g.undotree_ShortIndicators = 1 -- Shorter indicators pls
    vim.g.undotree_SplitWidth = 24 -- wider window pls
    vim.opt.undofile = true
  end,
}
