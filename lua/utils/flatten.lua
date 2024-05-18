---A replacement for vim.tbl_flatten
---@generic T
---@param ... T[]
---@return T[]
return function(...) return vim.iter({ ... }):flatten():totable() end
