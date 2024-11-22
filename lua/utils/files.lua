local M = {}

---@param name string
---@return integer?
local function find_buffer_by_name(name)
  return vim.iter(vim.api.nvim_list_bufs()):find(function(buf) return vim.api.nvim_buf_get_name(buf) == name end)
end

---Open file in the appropriate window.
---@param path string The file to open
---@param open_cmd string? The vim command to use to open the file
---@param bufnr number? The buffer number to open
function M.open(path, open_cmd, bufnr)
  if not path then return end
  open_cmd = open_cmd or "edit"
  bufnr = bufnr or find_buffer_by_name(path) -- If the file is already open, switch to it.
  if bufnr then
    local buf_cmd_lookup = { edit = "b", e = "b", split = "sb", sp = "sb", vsplit = "vert sb", vs = "vert sb" }
    local buf_open = buf_cmd_lookup[open_cmd]
    open_cmd = buf_open or open_cmd
    if not buf_open then bufnr = nil end
  end
  local cmd = assert(vim.cmd[open_cmd], "Invalid command: " .. open_cmd)
  return cmd(bufnr or vim.fn.fnameescape(path))
end

return M
