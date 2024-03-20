local create_autocmd = require("utils.create_autocmd")
local notifications = require("utils.notifications")
---@overload fun(opts?: {force?:boolean})
local M = setmetatable({}, {
  __call = function(m, ...) return m.format(...) end,
})

---@class Formatter
---@field name string
---@field primary? boolean
---@field format fun(bufnr:number): any?
---@field sources fun(bufnr:number):string[]
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
---@return (Formatter|{active:boolean,resolved:string[]})[]
function M.resolve(buf, all)
  buf = buf or vim.api.nvim_get_current_buf()
  local have_primary = false
  ---@param formatter Formatter
  local ret = vim.tbl_map(function(formatter)
    local sources = formatter.sources(buf)
    local active = #sources > 0 and (not formatter.primary or not have_primary)
    if active and formatter.primary then have_primary = true end
    return setmetatable({ active = active, resolved = sources }, { __index = formatter })
  end, M.formatters)
  if all then return ret end
  return vim.tbl_filter(function(formatter) return formatter.active end, ret)
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
  local have = false
  for _, formatter in ipairs(M.resolve(buf, true)) do
    if #formatter.resolved > 0 then
      have = true
      lines[#lines + 1] = "\n# " .. formatter.name .. (formatter.active and " ***(active)***" or "")
      for _, line in ipairs(formatter.resolved) do
        lines[#lines + 1] = ("- [%s] **%s**"):format(formatter.active and "x" or " ", line)
      end
    end
  end
  if not have then lines[#lines + 1] = "\n***No formatters available for this buffer.***" end
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
