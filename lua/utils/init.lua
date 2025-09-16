local M = {}

---A replacement for vim.tbl_flatten
---@generic T
---@param ... T[]
---@return T[]
function M.flatten(...) return vim.iter({ ... }):flatten(math.huge):totable() end

---Opens the nearest `filename` in the editor, or prints notifies
---@param filename string the filename to seach for
---@return boolean success true if file found, false if not found
function M.edit_closest(filename)
  local notifications = require("utils.notifications")
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

---Open file in the appropriate window.
---@param path string The file to open
---@param open_cmd string? The vim command to use to open the file
---@param bufnr number? The buffer number to open
function M.open(path, open_cmd, bufnr)
  if not path then return end
  open_cmd = open_cmd or "edit"
  bufnr = bufnr
    or vim.iter(vim.api.nvim_list_bufs()):find(function(buf) return vim.api.nvim_buf_get_name(buf) == path end) -- If the file is already open, switch to it.
  if bufnr then
    local buf_cmd_lookup = { edit = "b", e = "b", split = "sb", sp = "sb", vsplit = "vert sb", vs = "vert sb" }
    local buf_open = buf_cmd_lookup[open_cmd]
    open_cmd = buf_open or open_cmd
    if not buf_open then bufnr = nil end
  end
  local cmd = assert(vim.cmd[open_cmd], "Invalid command: " .. open_cmd)
  return cmd(bufnr or vim.fn.fnameescape(path))
end

---returns a boolean indicating whether the current nvim session is running in a tty
---@return boolean is_tty true if running in a tty, false otherwise
function M.is_tty()
  -- false in a SSH connection (likely in a terminal emulator)
  if vim.env.SSH_CLIENT or vim.env.SSH_TTY then return false end
  -- false if display is defined, else true
  return not vim.env.DISPLAY
end

-- this will return a function that calls telescope. cwd will default to the root
-- for `files`, git_files or find_files will be chosen depending on .git
function M.telescope(builtin, opts) ---@param builtin string
  local root = require("utils.root")
  local params = { builtin, opts } -- save original values of params
  return function()
    builtin, opts = table.unpack(params)
    opts = vim.tbl_deep_extend("force", { cwd = root.get() }, opts or {})
    return require("telescope.builtin")[builtin](opts)
  end
end

---Get the visual selection for the current buffer
---@return string? text nil if no visual selection is available
---Source: https://gitlab.com/jrop/dotfiles/-/blame/master/.config/nvim/lua/my/utils.lua#L17
function M.vtext()
  local mode = vim.fn.mode()
  if mode ~= "v" and mode ~= "V" and mode ~= "" then return nil end

  local lines = vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"), { type = vim.fn.mode() })
  return table.concat(lines, "\n")
end

return M
