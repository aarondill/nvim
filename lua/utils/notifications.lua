local M = {}
---May include other keys that are passed to vim.notify
---@alias NotifyOpts {lang?:string, level?:number, once?:boolean, [string]: unknown}

---Performs a shallow clone on tbl if it's a table
---@generic T
---@param tbl T
local function clone(tbl) ---@return T
  if type(tbl) ~= "table" then return tbl end
  local ret = {}
  for k, v in pairs(tbl) do
    ret[k] = v
  end
  return ret
end

---@param msg string|string[]
---@param opts NotifyOpts?
function M.notify(msg, opts)
  --- Note: do these before checking in_fast_event to ensure that if the table changes between calls, the message doesn't change.
  opts = clone(opts or {})
  ---@diagnostic disable-next-line: undefined-field tbl.n is valid
  if type(msg) == "table" then msg = table.concat(msg, "\n", 1, msg.n) end
  if vim.in_fast_event() then return vim.schedule(function() return M.notify(msg, opts) end) end
  local lang, level = opts.lang or "markdown", opts.level or vim.log.levels.INFO
  local n = opts.once and vim.notify_once or vim.notify
  ---@cast opts table
  local _on_open = opts.on_open ---@type (fun(win: integer): any)?
  opts.on_open = function(win) ---@param win integer
    local buf = vim.api.nvim_win_get_buf(win)
    local ok = pcall(vim.treesitter.language.add, "markdown")
    if not ok then pcall(require, "nvim-treesitter") end
    vim.wo[win].conceallevel = 3
    vim.wo[win].concealcursor = ""
    vim.wo[win].spell = false
    if not pcall(vim.treesitter.start, buf, lang) then
      vim.bo[buf].filetype = lang
      vim.bo[buf].syntax = lang
    end
    -- Call the user provided on_open if exists
    if _on_open then return _on_open(win) end
  end
  n(msg, level, opts)
end

---@param level number
local function create_notify_func(level)
  ---@param msg string|string[]
  ---@param opts NotifyOpts?
  return function(msg, opts)
    opts = clone(opts or {})
    assert(not opts.level, "You can't pass level while using specialized notify functions! Use notify() instead!")
    opts.level = level
    return M.notify(msg, opts)
  end
end
M.error = create_notify_func(vim.log.levels.ERROR)
M.info = create_notify_func(vim.log.levels.INFO)
M.warn = create_notify_func(vim.log.levels.WARN)

---@param msg unknown
---@param opts NotifyOpts?
function M.debug(msg, opts)
  if type(msg) ~= "string" then
    msg = vim.inspect(msg)
    opts = clone(opts or {})
    opts.lang = "lua"
  end
  return M.notify(msg, opts)
end

return M
