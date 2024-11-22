---Get the visual selection for the current buffer
---@return string? text nil if no visual selection is available
---Source: https://gitlab.com/jrop/dotfiles/-/blame/master/.config/nvim/lua/my/utils.lua#L17
local function vtext()
  local mode = vim.fn.mode()
  if mode ~= "v" and mode ~= "V" and mode ~= "" then return nil end

  local lines = vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"), { type = vim.fn.mode() })
  return table.concat(lines, "\n")
end

return vtext
