---@type LazySpec
return {
  { "ConradIrwin/vim-bracketed-paste", event = "VimEnter" }, -- Bracketed paste to escape charecters
  { "rhysd/conflict-marker.vim", event = { "BufReadPost", "BufNewFile", "BufWritePre" } }, -- detect git conflict markers
  { "NMAC427/guess-indent.nvim", event = { "BufReadPost", "BufNewFile", "BufWritePre" }, opts = {} }, -- Guess the current file indention type
  { "wsdjeg/vim-fetch", event = { "BufNewFile", "VimEnter" } }, -- Allow line numbers in file names
  { "micarmst/vim-spellsync", event = { "BufReadPost", "BufNewFile", "BufWritePre" } }, -- Rebuild spell files on file open
}
