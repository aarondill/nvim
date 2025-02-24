local flatten = require("utils.flatten")
---@type LazySpec
return {
  "supermaven-inc/supermaven-nvim",
  main = "supermaven-nvim",
  event = { "LazyFile" },
  cmd = flatten({
    { "SupermavenUseFree", "SupermavenLogout", "SupermavenUsePro" },
    { "SupermavenStart", "SupermavenStop", "SupermavenRestart", "SupermavenStatus" },
  }),
  opts = {
    log_level = "warn",
    ignore_filetypes = vim.iter(require("consts").ignored_filetypes):fold({}, function(acc, v)
      acc[v] = true
      return acc
    end),
    disable_keymaps = true,
  },
}
