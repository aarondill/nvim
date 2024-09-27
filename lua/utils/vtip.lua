local cache = vim.fn.stdpath("cache") --[[@as string]]
local notifications = require("utils.notifications")
local M = {
  file = vim.fs.joinpath(cache, "vtip.log"),
  ---@param res string
  notify = function(res)
    return notifications.info(res, {
      title = "In Case You Didn't Know!",
      timeout = 5000,
    })
  end,
  ---@param err string
  error = function(err)
    return notifications.error(err, {
      title = "Error fetching VTip",
      timeout = 5000,
    })
  end,
  url = "https://vtip.43z.one",
}

---Fetch a new VTip
---If callback is not provided, the VTip will be shown via vim.notify
---@param on_success? fun(res: string): any?
---@param on_error? fun(err: string): any?
function M.fetch(on_success, on_error)
  on_success, on_error = on_success or M.notify, on_error or M.error
  local ok = pcall(vim.system, { "curl", "-SsfL", M.url }, { timeout = 3 * 1000 }, function(obj)
    if obj.code == 124 then return end -- Timeout
    if obj.code ~= 0 or obj.signal ~= 0 then
      if obj.code == 6 then return end -- Could not resolve host
      if obj.code == 7 then return end -- Failed to connect
      local err = vim.trim(table.concat({ obj.stdout, obj.stderr }, "\n"))
      return on_error(err)
    end
    local res = assert(obj.stdout, "No stdout from curl") -- this isn't possible

    vim.schedule(function() -- Writefile has to be scheduled
      vim.fn.mkdir(vim.fs.dirname(M.file), "p") -- Create the directory if it doesn't exist
      local write_res = vim.split(res, "\n", { plain = true, trimempty = true }) -- writefile expects a list of lines
      vim.fn.writefile(write_res, M.file, "a") -- Append the tip to the cache file
    end)
    return on_success(res)
  end)
  if ok then return end
  return on_error("Could not spawn curl")
end

--- Open a popup with the VTip history
function M.history()
  if vim.fn.filereadable(M.file) == 0 then return notifications.info("VTip history is empty") end
  local ok, lines = pcall(vim.fn.readfile, M.file)
  if not ok then return notifications.error("Could not read VTip history: " .. lines) end
  if #lines == 0 then return notifications.info("VTip history is empty") end
  lines = vim.tbl_map(function(line) return line:gsub("\n", "\0") end, lines) --- Replace newlines with null bytes

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = "vtip"
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].swapfile = false

  local width = math.floor(vim.o.columns * 0.5)
  local height = math.floor(vim.o.lines * 0.5)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    zindex = 50,
    border = "single",
    title = "VTip History",
    title_pos = "center",
  })
  vim.keymap.set("n", "q", function() -- Close the window when the user presses q
    return vim.api.nvim_win_close(win, true)
  end, { buffer = buf, nowait = true })

  vim.wo[win].number = true

  vim.api.nvim_win_set_buf(win, buf)
  -- Scroll to the bottom
  vim.api.nvim_win_set_cursor(win, { vim.fn.line("$", win), 0 })
end

--- Clear the VTip history
function M.clear()
  local ok, err = vim.uv.fs_unlink(M.file)
  if not ok and err then
    local msg = "Could not delete VTip cache file: " .. err
    return notifications.error(msg)
  end
end

return M
