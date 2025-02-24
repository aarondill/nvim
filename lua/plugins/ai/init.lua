local notifications = require("utils.notifications")
local ok
vim.system(
  { "ping", "-c1", "1.1.1.1" },
  { timeout = 3000, stderr = false, stdout = false },
  function(obj) ok = obj.code == 0 and obj.signal == 0 end
)
---@return boolean
local function internet()
  if ok == nil and not vim.wait(10000, function() return ok ~= nil end, 200, true) then
    ok = false -- The wait was timed out, assume no internet
  end
  if not ok then notifications.warn("No internet connection, using Tabnine instead of Supermaven!", { once = true }) end
  return ok
end

---@type LazySpec
return {
  { import = "plugins.ai" },
  { "supermaven-nvim", optional = true, cond = internet },
  {
    "tabnine-nvim",
    optional = true,
    cond = function() return not internet() end,
  },
}
