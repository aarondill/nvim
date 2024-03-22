---@alias BigFileConfig config

---@type LazySpec
return {
  "LunarVim/bigfile.nvim",
  ---@type BigFileConfig|{}
  opts = { filesize = 1 },
  -- event = { "BufReadPre", "BufNewFile", "BufEnter" },
  lazy = false,
  priority = 2000,
}
