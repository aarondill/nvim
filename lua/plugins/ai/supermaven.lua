local flatten = require("utils.flatten")
---@type LazySpec
return {
  "supermaven-inc/supermaven-nvim",
  main = "supermaven-nvim",
  event = "InsertEnter",
  config = function(_, opts)
    local r = require ---HACK: Don't load cmp with supermaven. I don't want its integration.
    require = function(...)
      if select(1, ...) == "cmp" then error("Thou shall not use cmp with Supermaven") end
      return r(...)
    end
    require("supermaven-nvim").setup(opts)
    require = r
  end,
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
