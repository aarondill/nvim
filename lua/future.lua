-- Fowards compatability:
table.pack = table.pack or function(...) return { n = select("#", ...), ... } end
table.unpack = table.unpack or unpack
local uv = vim.uv or vim.loop
vim.uv, vim.loop = uv, uv
---@param ... string
---@return string
vim.fs.joinpath = vim.fs.joinpath or function(...) return (table.concat({ ... }, "/"):gsub("//+", "/")) end
