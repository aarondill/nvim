local M = {}

--- Runs the function and inserts it's result to the
---@param str string
---@param newline? boolean
function M.insert(str, newline)
  newline = newline or false
  local row = (vim.api.nvim_win_get_cursor(0))[1]
  -- Insert a line after the cursor
  return vim.schedule(function()
    if newline then
      local lines = vim.fn.split(str, "\n", 1)
      vim.api.nvim_buf_set_lines(0, row, row, true, lines)
      local last_line = lines[#lines]
      return vim.api.nvim_win_set_cursor(0, { row + #lines, #last_line }) -- Cursor to end of text
    else
      return vim.api.nvim_put({ str }, "", true, true)
    end
  end)
end

---@param start? integer first line to include (1-indexed)
---@param _end? integer last line to include (1-indexed)
---@param keep_last boolean?
---@return integer count of lines removed
function M.dedupe_lines(start, _end, keep_last)
  local reverse = keep_last or false
  local i = start or 1
  local lines = _end or assert(vim.fn.line("$"))
  local initial_lines = math.max(lines, i)
  if reverse then -- loop backwards
    local tmp = lines
    lines, i = i, tmp
  end

  local seen_lines = {} ---@type table<string, integer>
  while true do -- we can't use a i=0,lines because lines changes
    if reverse and i < lines then break end
    if not reverse and i > lines then break end
    --- NOTE: i is 1-indexed, vim.api.nvim_* are 0-indexed
    local line = vim.api.nvim_buf_get_lines(0, i - 1, i, true)[1]

    if not seen_lines[line] then
      seen_lines[line] = i
      -- incr i only when we haven't removed the line
      i = i + (reverse and -1 or 1)
    else -- Remove the line
      -- If reverse, remove the first instance, else remove the current instance
      vim.api.nvim_buf_set_lines(0, i - 1, i, true, {})
      if reverse then
        i = i - 1
      else
        lines = lines - 1
      end
    end
  end
  return initial_lines - lines
end

return M
