---Sets vim.env.PATH with the path given added to it.
---@param path string the path to append to the vim.env.PATH
---@param append? boolean whether to append or prepend the path. false means prepend. has no effect if path is empty.
---@return string new_PATH
---@return string old_PATH
return function(path, append)
  append = append == nil and true or append
  local r = path
  -- If empty or unset, ignore
  if vim.env.PATH and vim.env.PATH ~= "" then
    if append then
      r = vim.env.PATH .. ":" .. path
    else
      r = path .. ":" .. vim.env.PATH
    end
  end
  local old_PATH = vim.env.PATH
  local new_PATH = r
  vim.env.PATH = new_PATH
  return new_PATH, old_PATH
end
