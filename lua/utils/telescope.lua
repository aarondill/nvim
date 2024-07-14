local root = require("utils.root")
local M = {}

-- this will return a function that calls telescope. cwd will default to the root
-- for `files`, git_files or find_files will be chosen depending on .git
function M.telescope(builtin, opts) ---@param builtin string
  local params = { builtin, opts } -- save original values of params
  return function()
    builtin, opts = table.unpack(params)
    opts = vim.tbl_deep_extend("force", { cwd = root.get() }, opts or {})
    return require("telescope.builtin")[builtin](opts)
  end
end

return setmetatable(M, { __call = function(_, ...) return M.telescope(...) end })
