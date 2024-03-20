return {
  "gsuuon/tshjkl.nvim",
  opts = {
    keymaps = {
      toggle = "<leader>ct",
    },
  },
  keys = function(self) return vim.tbl_values(self.opts.keymaps) end,
}
