local create_autocmd = require("utils.create_autocmd")
---@param buf number
local function create_help_window(buf)
  local editor = { width = vim.o.columns, height = vim.o.lines }
  local window = {
    width = math.floor(editor.width * 0.8),
    height = math.floor(editor.height * 0.8),
  }
  return vim.api.nvim_open_win(buf, true, {
    style = "minimal",
    border = "double",
    zindex = 50,
    relative = "editor",
    width = window.width,
    height = window.height,
    row = (editor.height - window.height) / 2,
    col = (editor.width - window.width) / 2,
  })
end

create_autocmd({ "BufWinEnter" }, function(e)
  if vim.bo[e.buf].filetype ~= "help" then return end
  local old_win = vim.api.nvim_get_current_win()
  local new_win = create_help_window(e.buf)
  vim.wo[new_win].scroll = vim.wo[old_win].scroll -- Keep scroll position
  vim.api.nvim_win_close(old_win, false) -- Close old help window
end, { group = vim.api.nvim_create_augroup("float-help", { clear = true }) })
