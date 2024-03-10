---Returns a boolean indicating whether a package is present (through lazy)
---@param plugin string the plugin name (after the slash)
---@return boolean
return function(plugin)
  local mod = require("lazy.core.config")
  return mod.plugins[plugin] ~= nil
end
