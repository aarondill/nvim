---returns a boolean indicating whether the current nvim session is running in a tty
---@return boolean is_tty true if running in a tty, false otherwise
return function()
  -- false in a SSH connection (likely in a terminal emulator)
  if vim.env.SSH_CLIENT or vim.env.SSH_TTY then return false end
  -- false if display is defined, else true
  return not vim.env.DISPLAY
end
