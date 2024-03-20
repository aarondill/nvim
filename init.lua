require("future") -- Fowards compatability

-- Override .pluto and .tmpl extensions
vim.filetype.add({
  extension = {
    [".pluto"] = "lua",
    [".tmpl"] = function(path) return vim.fs.basename(path):match(".+%.(.+).tmpl$") end,
  },
})

if vim.fn.has("nvim-0.9.0") == 0 then
  vim.api.nvim_echo({
    { "This configurations requires Neovim >= 0.9.0\n", "ErrorMsg" },
    { "Aborting configuration. You will be left with Vanilla Neovim.\n", "ErrorMsg" },
    { "Press any key to continue.", "MoreMsg" },
  }, true, {})
  vim.fn.getchar()
  return
end

require("config.options") -- This needs to come first!
require("config.lazy") -- bootstrap lazy.nvim and plugins

-- Require all the files in ./config
require("lazy.core.util").lsmod("config", require)

--- Handle regenerating helptags in new VIMRUNTIMEs
local rt = os.getenv("VIMRUNTIME")
if rt and vim.loop.fs_access(rt, "W") then
  --- Regen the helptags
  vim.cmd.helptags(vim.fs.joinpath(rt, "doc"))
end
