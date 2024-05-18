---This is a hard-coded list taken from the source.
local cmd = require("utils.flatten")(
  { "G", "GBrowse", "Gcd", "Gclog", "GcLog", "GDelete", "Gdiffsplit", "Gdrop", "Ge", "Gedit", "Ggrep" },
  { "Ghdiffsplit", "Git", "Glcd", "Glgrep", "Gllog", "GlLog", "GMove", "Gpedit", "Gr", "Gread", "GRemove" },
  { "GRename", "Gsplit", "Gtabedit", "GUnlink", "Gvdiffsplit", "Gvsplit", "Gw", "Gwq", "Gwrite" }
)
---@type LazySpec
return {
  "tpope/vim-fugitive",
  cmd = cmd,
  dependencies = {
    { "aymericbeaumet/vim-symlink", dependencies = { "moll/vim-bbye" } },
  },
}
