---@type LazySpec
return {
  { "ConradIrwin/vim-bracketed-paste", event = "VimEnter" }, -- Bracketed paste to escape charecters
  { "rhysd/conflict-marker.vim", event = "LazyFile" }, -- detect git conflict markers
  { "NMAC427/guess-indent.nvim", event = "LazyFile", opts = {} }, -- Guess the current file indention type
}
