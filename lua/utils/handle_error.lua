local notifications = require("utils.notifications")
---Run func and notify on error
---Not typed because generics can't handle it properly
local function handle_error(func)
  return function(...)
    local ok, val_or_err = pcall(func, ...)
    if ok then return val_or_err end
    return notifications.error(val_or_err)
  end
end

return handle_error
