---@type LazySpec
return {
  "lambdalisue/vim-suda",
  cond = vim.fn.executable(vim.g["suda#executable"] or "sudo") == 1,
  cmd = { "SudaRead", "SudaWrite" },
  -- init = function()
  --   vim.g.suda_smart_edit = 1
  -- end,
  -- -- Load on enter *any* file, required for smart editing.
  -- event = {
  --   "BufReadPre",
  --   "BufNewFile",
  --   -- "BufEnter"
  -- },
}
