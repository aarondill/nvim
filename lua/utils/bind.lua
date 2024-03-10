local pack = table.pack or vim.F.pack_len
local unpack = table.unpack or unpack

--- return a new array containing the concatenation of all of its
--- parameters. Array parameters have their values shallow-copied
--- to the final array. All parameters are must be tables, or else
-- an error is thrown.
---@param ... unknown[] a set of table to join together
---@return table joined a new table containing the concatenation
local function tbl_join(...)
  local t = {}
  local tn = 0
  for n = 1, select("#", ...) do
    local arg = select(n, ...)
    if type(arg) ~= "table" then
      error(string.format("invalid argument '#%d': expected table, got %s", n, type(arg)), 2)
    end
    for argn = 1, (arg.n or #arg) do
      local v = arg[argn]
      tn = tn + 1
      t[tn] = v
    end
  end
  t.n = tn
  return t
end

local M = {}
---returns a curried function that represents f(args)
---Note: The types here don't actually work. Don't rely on them for diagnostic purposes.
---@generic args, return
---@param f fun(...:args): return
---@param ... args
---@return fun(): return
function M.with(f, ...)
  local args = pack(...)
  return function() return f(unpack(args, 1, args.n)) end
end

---returns a curried function that represents f(args, other_args)
---Note: The types here don't actually work. Don't rely on them for diagnostic purposes.
---@generic args, rest, return
---@param f fun(...:args, ...:rest): return
---@param ... args
---@return fun(...:rest): return
function M.bind(f, ...)
  local len = select("#", ...)
  local outer = len > 0 and pack(...) or nil -- nil if no arguments are passed
  return function(...)
    if not outer then return f(...) end -- save processing/memory in storing the above table
    local args = select("#", ...) > 0 and tbl_join(outer, pack(...)) or outer -- Avoid the copy if possible
    return f(unpack(args, 1, args.n))
  end
end

return setmetatable(M, {
  __call = function(_, ...) return M.bind(...) end,
})
