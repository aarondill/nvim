local create_autocmd = require("utils.create_autocmd")
local M = {}

---@type table<string,LazyFloat>
local terminals = {}

---@class TermOpts :LazyCmdOptions
---@field interactive? boolean
---@field esc_esc? boolean
---@field ctrl_hjkl? boolean

---Opens a floating terminal using lazy.util.float_term (interactive by default)
---@param cmd? string[]|string
---@param opts? TermOpts
function M.open(cmd, opts)
  opts = vim.tbl_deep_extend("force", {
    ft = "lazyterm",
    size = { width = 0.9, height = 0.9 },
  }, opts or {}, { persistent = true }) --[[@as TermOpts]]

  local termkey = vim.inspect({ cmd = cmd or "shell", cwd = opts.cwd, env = opts.env, count = vim.v.count1 })

  local t = terminals[termkey]
  if t and t:buf_valid() then
    t:toggle()
    return t
  end
  t = require("lazy.util").float_term(cmd, opts)
  terminals[termkey] = t

  local unmaps = opts.ctrl_hjkl and {} or { "<c-h>", "<c-j>", "<c-k>", "<c-l>" }
  if opts.esc_esc == false then table.insert(unmaps, "<esc>") end
  for _, key in ipairs(unmaps) do
    vim.keymap.set("t", key, key, { buffer = t.buf, nowait = true })
  end
  create_autocmd("BufEnter", "startinsert", { buffer = t.buf })
  return t
end

return M
