---@type LazySpec
return {
  "nvim-lua/plenary.nvim",
  optional = true,
  cmd = {
    "PlenaryBustedFile",
    "PlenaryBustedDirectory",
  },
  keys = {
    "<Plug>PlenaryTestFile",
  },
}
