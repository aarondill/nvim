local create_autocmd = require("utils.create_autocmd")
local notifications = require("utils.notifications")
--- Skeleton for new files, %s will be the name of the file (without extension)
local SKEL = [[
# TODO(%s)
- ]]

local function handle_todo(e) ---@param e EventInfo
  vim.cmd.filetype("detect") -- HACK: Ensure filetype detection gets a chance to run
  --- If the filetype was already detected, don't do anything
  if vim.fn.did_filetype() ~= 0 then return end
  vim.bo[e.buf].filetype = "markdown"
end
--- Escape a pattern for use in an autocmd
local function pattern_escape(pattern) ---@param pattern string
  return vim.fn.escape(pattern, "*?{}\\[]")
end

--- Handle all files under "$(todo path)"
--- Sets the filetype to markdown if it's not already set
--- Creates a skeleton for new files
local setup_todos = vim.schedule_wrap(function(path) ---@param path string
  local group = vim.api.nvim_create_augroup("todos", { clear = true })
  local pattern = vim.fs.joinpath(pattern_escape(path), "*")

  create_autocmd({ "BufRead", "BufNewFile" }, handle_todo, { group = group, pattern = pattern })

  create_autocmd({ "BufNewFile" }, function(e)
    local name = vim.fn.fnamemodify(e.file, ":t:r")
    local content = SKEL:format(name)
    vim.api.nvim_buf_set_lines(e.buf, 0, -1, false, vim.split(content, "\n"))
    local line = vim.fn.line("$")
    local col = #vim.api.nvim_buf_get_lines(e.buf, line - 1, line, false)
    vim.api.nvim_win_set_cursor(0, { line, col })

    -- This doens't count as a change, don't prompt on delete
    vim.bo[e.buf].modified = false
  end, { group = group, pattern = pattern })

  --- Load for the current buffer
  vim.api.nvim_exec_autocmds("BufRead", { group = group })

  --- Check if the current file exists, if not fire the BufNewFile autocmd
  local current_file = vim.api.nvim_buf_get_name(0)
  if not vim.uv.fs_stat(current_file) then
    vim.api.nvim_exec_autocmds("BufNewFile", { group = group, pattern = current_file })
  end
end)

--- Ignore errors, if the user doesn't have the todo script installed, don't do anything.
pcall(vim.system, { "todo", "path" }, { text = true }, function(obj)
  if obj.code ~= 0 or obj.signal ~= 0 then return notifications.error("todo: error: " .. obj.stderr) end
  local path = vim.trim(obj.stdout)
  return setup_todos(path)
end)

create_autocmd({ "BufRead", "BufNewFile" }, handle_todo, {
  --- \\c is used to ignore case
  pattern = { "\\ctodo", "\\creminder" },
})
