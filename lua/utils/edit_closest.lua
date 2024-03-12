local notifications = require("utils.notifications")
---Opens the nearest `filename` in the editor, or prints notifies
---@param filename string the filename to seach for
---@return boolean success true if file found, false if not found
return function(filename)
  local match = vim.fs.find(filename, { upward = true, limit = 1, type = "file" })
  local file = match[1]
  if not file then
    notifications.warn("Could not find file: " .. filename)
    return false
  end
  notifications.info("Editing " .. vim.fn.fnamemodify(file, ":~:."))
  vim.cmd.edit(file)
  return true
end
