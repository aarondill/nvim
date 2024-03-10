local M = {}
---@class IndentInfo
---@field size integer
---@field tabs boolean

---@return IndentInfo
function M.get_indent(buf) ---@param buf integer?
  local expandtab = vim.api.nvim_get_option_value("expandtab", { buf = buf }) ---@type boolean
  local shiftwidth = vim.api.nvim_get_option_value("shiftwidth", { buf = buf }) ---@type integer

  if not expandtab or shiftwidth == 0 then return { size = 1, tabs = true } end -- If using tab indentation, use tabs
  return { size = shiftwidth, tabs = false } -- Use spaces, according to the current settings
end
return M
