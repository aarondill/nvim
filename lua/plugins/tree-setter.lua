---@type LazySpec
return {
  "filNaj/tree-setter",
  dependencies = { "nvim-treesitter/nvim-treesitter", opts = { tree_setter = { enable = true } } },
  event = "LazyFile",
}
