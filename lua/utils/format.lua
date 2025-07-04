local create_autocmd = require("utils.create_autocmd")
local notifications = require("utils.notifications")
---@overload fun(opts?: {force?:boolean})
local M = setmetatable({}, {
  __call = function(m, ...) return m.format(...) end,
})

---@class Formatter
---The display name of the formatter
---@field name string
---Whether this formatter is the primary formatter for the buffer (only one primary formatter will be used)
---@field primary? boolean
---The function to call to format the buffer
---@field format fun(bufnr:number): any?
---The function to get the sources for the formatter, return empty array if can't format
---@field sources fun(bufnr:number):string[]
---The priority of the formatter, formatters with higher priority will be used first (and run first)
---@field priority number

M.formatters = {} ---@type Formatter[]

---@param formatter Formatter
function M.register(formatter)
  M.formatters[#M.formatters + 1] = formatter
  table.sort(M.formatters, function(a, b) return a.priority > b.priority end)
end

function M.formatexpr()
  local has_conform, conform = pcall(require, "conform")
  if has_conform then return conform.formatexpr() end
  return vim.lsp.formatexpr({ timeout_ms = 3000 })
end

---@param buf? integer
---@param all? boolean return even inactive formatters (default: false)
---@return  (Formatter|{active:boolean,resolved:string[]})[] formatters,boolean have_active
function M.resolve(buf, all)
  buf = buf or vim.api.nvim_get_current_buf()
  local have_primary, have_active = false, false
  ---@param formatter Formatter
  local ret = vim.tbl_map(function(formatter)
    local sources = formatter.sources(buf)
    local active = #sources > 0 and (not formatter.primary or not have_primary)
    if active and formatter.primary then have_primary = true end
    if active then have_active = true end
    return setmetatable({ active = active, resolved = sources }, { __index = formatter })
  end, M.formatters)
  if all then return ret, have_active end
  return vim.tbl_filter(function(formatter) return formatter.active end, ret), have_active
end

---@param buf? integer
function M.info(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local gaf = vim.g.autoformat == nil or vim.g.autoformat
  local baf = vim.b[buf].autoformat
  local enabled = M.enabled(buf)
  local lines = {
    "# Status",
    ("- [%s] global **%s**"):format(gaf and "x" or " ", gaf and "enabled" or "disabled"),
    ("- [%s] buffer **%s**"):format(
      enabled and "x" or " ",
      (baf == nil and "inherit") or (baf and "enabled") or "disabled"
    ),
  }
  local formatters, have_active = M.resolve(buf, true)
  for _, formatter in ipairs(formatters) do
    if #formatter.resolved > 0 then
      lines[#lines + 1] = ""
      lines[#lines + 1] = "# " .. formatter.name .. (formatter.active and " ***(active)***" or "")
      for _, line in ipairs(formatter.resolved) do
        lines[#lines + 1] = ("- [%s] **%s**"):format(formatter.active and "x" or " ", line)
      end
    end
  end
  if have_active then
    local active = vim.tbl_filter(function(formatter) return formatter.active end, formatters)
    lines[#lines + 1] = ""
    lines[#lines + 1] = "# Active formatters in order"
    for _, formatter in ipairs(active) do
      lines[#lines + 1] = ("- **%s** (priority %d)"):format(formatter.name, formatter.priority)
    end
  else
    lines[#lines + 1] = ""
    lines[#lines + 1] = "***No formatters available for this buffer.***"
  end
  notifications.info(lines, { title = ("Formatting (%s)"):format((enabled and "enabled" or "disabled")) })
end

---@param buf? number
function M.enabled(buf)
  if not buf or buf == 0 then buf = vim.api.nvim_get_current_buf() end
  local gaf, baf = vim.g.autoformat, vim.b[buf].autoformat
  if baf ~= nil then return baf end -- If the buffer has a local value, use that
  return gaf == nil or gaf -- Otherwise use the global value if set, or true by default
end

---@param buf? boolean|integer
function M.toggle(buf)
  local new = not M.enabled()
  if buf then
    buf = type(buf) == "boolean" and vim.api.nvim_get_current_buf() or buf
    vim.b[buf].autoformat = new
  else
    vim.g.autoformat, vim.b.autoformat = new, nil
  end
  M.info()
end

---@param opts? {force?:boolean, buf?:number}
function M.format(opts)
  opts = opts or {}
  local buf = opts.buf or vim.api.nvim_get_current_buf()
  if not opts.force and not M.enabled(buf) then return end

  local formatters = M.resolve(buf)
  for _, formatter in ipairs(formatters) do
    local ok, err = pcall(formatter.format, buf)
    if not ok then notifications.error(("Formatter `%s` failed: %s"):format(formatter.name, err)) end
  end

  if #formatters == 0 and opts and opts.force then notifications.warn("No formatter available") end
end

-- Autoformat autocmd
create_autocmd("BufWritePre", function(ev) M.format({ buf = ev.buf }) end, "Autoformat on save", {
  group = vim.api.nvim_create_augroup("formatting", { clear = true }),
})
vim.api.nvim_create_user_command("Format", function() --
  return M.format({ force = true })
end, { desc = "Format selection or buffer" })
vim.api.nvim_create_user_command("FormatInfo", function() --
  return M.info()
end, { desc = "Show info about the formatters for the current buffer" })

return M
