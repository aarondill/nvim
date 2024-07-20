local M = {}
local defaults = { timeout_ms = 3000, async = false, quiet = false, lsp_fallback = true }

---@param opts? Formatter| {filter?: (string|vim.lsp.get_clients.Filter)}
---@return Formatter
function M.formatter(opts)
  opts = opts or {}
  local filter = opts.filter or {}
  filter = type(filter) == "string" and { name = filter } or filter ---@cast filter vim.lsp.get_clients.Filter
  local ret = { ---@type Formatter
    name = "LSP",
    primary = true,
    priority = 1,
    format = function(buf) M.format(vim.tbl_extend("force", filter, { bufnr = buf })) end,
    sources = function(buf)
      local clients = vim.lsp.get_clients(vim.tbl_extend("force", filter, { bufnr = buf }))
      local ret = vim.tbl_filter(function(client) --@param client vim.lsp.Client
        return client.supports_method("textDocument/formatting")
          or client.supports_method("textDocument/rangeFormatting")
      end, clients)
      ---@param client vim.lsp.Client
      return vim.tbl_map(function(client) return client.name end, ret)
    end,
  }
  return vim.tbl_extend("force", ret, opts)
end

---@alias lsp.Client.format {timeout_ms?: number, format_options?: table} | vim.lsp.get_clients.Filter

---@param opts? vim.lsp.buf.format.Opts
function M.format(opts)
  opts = vim.tbl_deep_extend("force", opts or {}, defaults)
  local ok, conform = pcall(require, "conform")
  -- use conform for formatting with LSP when available,
  if not ok then return vim.lsp.buf.format(opts) end
  local conform_opts = opts --[[@as conform.FormatOpts]]
  conform_opts.formatters = {}
  return conform.format(conform_opts)
end

return M
