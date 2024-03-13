---@type LazySpec
return {
  { "ConradIrwin/vim-bracketed-paste", event = "VimEnter" }, -- Bracketed paste to escape charecters
  { "rhysd/conflict-marker.vim", event = { "BufReadPost", "BufNewFile", "BufWritePre" } }, -- detect git conflict markers
  { "NMAC427/guess-indent.nvim", event = { "BufReadPost", "BufNewFile", "BufWritePre" }, opts = {} }, -- Guess the current file indention type
}
