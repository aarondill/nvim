return function(firstOp, thenOp)
  local pos = vim.api.nvim_win_get_cursor(0)
  vim.cmd("normal! " .. firstOp)
  local newpos = vim.api.nvim_win_get_cursor(0)
  vim.cmd("normal! " .. firstOp)
  -- Compare string representations of tables. Works bc simple tables (ie {2, 3})
  if table.concat(pos) == table.concat(newpos) then vim.cmd("normal! " .. thenOp) end
end
