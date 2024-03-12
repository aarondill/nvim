---Get the visual selection for the current buffer
---@return string? text nil if no visual selection is available
---Source: https://gitlab.com/jrop/dotfiles/-/blame/master/.config/nvim/lua/my/utils.lua#L17
local function vtext()
  local mode = vim.fn.mode()
  if mode ~= "v" and mode ~= "V" and mode ~= "" then return nil end
  local a_orig = vim.fn.getreg("a")
  vim.cmd([[silent! normal! "aygv]])
  local text = vim.fn.getreg("a")
  vim.fn.setreg("a", a_orig)
  assert(type(text) == "string", "Something went wrong getting the visual selection!")
  return text
end

return vtext
