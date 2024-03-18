local root = require("utils.root")
local M = {}

function M.telescope_files(opts)
  opts = opts or {}
  local cwd = opts.cwd or vim.loop.cwd()
  for _, f in ipairs({ ".git", ".ignore", ".rgignore" }) do
    if vim.loop.fs_stat(vim.fs.joinpath(cwd, f)) then return require("telescope.builtin").git_files(opts) end
  end
  return require("telescope.builtin").find_files(opts)
end
-- this will return a function that calls telescope. cwd will default to the root
-- for `files`, git_files or find_files will be chosen depending on .git
function M.telescope(builtin, opts) ---@param builtin string
  local params = { builtin, opts } -- save original values of params
  return function()
    builtin, opts = table.unpack(params)
    opts = vim.tbl_deep_extend("force", { cwd = root.get() }, opts or {})
    if builtin == "files" then return M.telescope_files(opts) end
    return require("telescope.builtin")[builtin](opts)
  end
end

return setmetatable(M, {__call=function(_, ...) return M.telescope(...) end})
