local flatten = require("utils.flatten")

local function internet()
  -- Wait 2 seconds at max
  local obj = vim.system({ "ping", "-c1", "1.1.1.1" }, { timeout = 2000 }):wait()
  return obj.code == 0 and obj.signal == 0
end
local has_internet = internet()
if not has_internet then
  require("utils.notifications").warn("No internet connection, using Tabnine instead of Supermaven!")
end

---@type LazySpec
return {
  {
    "supermaven-inc/supermaven-nvim",
    main = "supermaven-nvim",
    event = { "LazyFile" },
    cond = has_internet,
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
  },
  { "tabnine-nvim", optional = true, cond = not has_internet },
}
