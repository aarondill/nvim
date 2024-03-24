---@type LazySpec
return {
  {
    "smjonas/inc-rename.nvim",
    main = "inc_rename",
    opts = {},
    cmd = "IncRename",
  },
  {
    "folke/noice.nvim",
    optional = true,
    opts = { presets = { inc_rename = true } },
  },
}
