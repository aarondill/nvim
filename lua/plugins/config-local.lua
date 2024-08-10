---@type LazySpec
return {
  "klen/nvim-config-local",
  main = "config-local",
  lazy = false,
  opts = {
    config_files = { ".nvim.lua", ".nvimrc", ".nvimrc.lua", ".exrc", ".nvim/init.lua" }, -- Config file patterns to load (lua supported)
    lookup_parents = true, -- Lookup config files in parent directories
    -- silent = false, -- Disable plugin messages (Config loaded/ignored)
  },
}
