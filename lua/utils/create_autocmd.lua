---@class EventInfo
---@field id number autocommand id
---@field event string name of the triggered event `autocmd-events`
---@field group? number autocommand group id, if any
---@field match string expanded value of `<amatch>`
---@field buf number expanded value of `<abuf>`
---@field file string expanded value of `<afile>`
---@field data any arbitrary data passed from `nvim_exec_autocmds()`

-- A wrapper around |vim.api.nvim_create_autocmd| which reorganizes the paramaters
---@param event string|string[]
---@param rhs (fun(ev: EventInfo): boolean?)|string
---@param opts? vim.api.keyset.create_autocmd
return function(event, rhs, opts)
  opts = vim.deepcopy(opts or {})
  opts.command, opts.callback = nil, nil
  if type(rhs) == "string" then
    opts.command = rhs
  else
    opts.callback = rhs
  end
  return vim.api.nvim_create_autocmd(event, opts)
end
