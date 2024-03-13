-- A wrapper around |vim.keymap.set| which adds a desc arg and allows multiple lhs to be defined at the same time
---@param mode string|string[] Mode short-name, see |nvim_set_keymap()|.
---@param lhs string|string[]  Left-hand side |{lhs}| of the mapping.
---@param rhs string|function  Right-hand side |{rhs}| of the mapping, can be a Lua function.
---@param desc string?         Description or opts
---@param opts table?          Table of |:map-arguments|. (If desc is defined, will be overwritten by arg)
---@overload fun(mode:string|string[], lhs:string|string[], rhs:string|function, opts:table)
return function(mode, lhs, rhs, desc, opts)
  if type(desc) == "string" then
    opts = vim.tbl_extend("force", opts or {}, { desc = desc })
  else
    assert((desc == nil or type(desc) == "table") and opts == nil, "Desc can only be a table if opts is nil")
    opts = desc
  end
  opts = opts or {}

  assert(type(lhs) == "table" or type(lhs) == "string", "lhs must be a string or table")
  local lhsT
  if type(lhs) == "table" then
    lhsT = lhs
  else
    lhsT = { lhs }
  end
  for _, l in pairs(lhsT) do
    vim.keymap.set(mode, l, rhs, opts)
  end
end
