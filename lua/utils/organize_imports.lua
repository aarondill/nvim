local M = {}
---@alias organize_imports_command string|fun(self: vim.lsp.Client, bufnr: integer):string?

---Mapping of lsp names (vim.lsp.get_clients) to commands. Special name
---`default` is used if no key is found. If function, it is called and may
---optionally return a string. If a string, passed as an argument to
---`vim.lsp.buf_request_sync` with method `workspace/executeCommand`
---@type table<string, organize_imports_command>
M.server_commands = {
  default = "source.organizeImports",
  ["ts_ls"] = "_typescript.organizeImports",
  ["jdtls"] = function() require("jdtls").organize_imports() end,
}
M.skip = {
  jdtls = true, -- JAVA is dumb and removes all imports on a syntax error
}

---@param bufnr integer
---@param force? boolean
local function get_clients(bufnr, force)
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  -- This client does not support the workspace/executeCommand method
  local supported = vim.tbl_filter(
    function(client) return client:supports_method("workspace/executeCommand", bufnr) end,
    clients
  )
  if force then return supported end
  return vim.tbl_filter(function(client) return not M.skip[client.name] end, supported)
end

---@param bufnr? integer
---@param force? boolean
function M.organize_imports(bufnr, force)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local clients = get_clients(bufnr, force)
  for _, client in ipairs(clients) do -- run on each lsp client
    local name = client.name
    ---@type organize_imports_command?
    local command = M.server_commands[name] or M.server_commands.default
    if type(command) == "function" then command = command(client, bufnr) end
    if command then -- If there's a command, or the function returned a command, run it
      client:request_sync(
        "workspace/executeCommand",
        { command = command, arguments = { vim.api.nvim_buf_get_name(bufnr) } },
        nil,
        bufnr
      )
    end
  end
end

---@param opts? Formatter| {filter?: (string|vim.lsp.buf.format.Opts)}
---@return Formatter
function M.formatter(opts)
  ---@type Formatter
  local ret = {
    name = "Organize Imports (LSP)",
    primary = false,
    priority = 3000, -- This should run before other formatters (since it messes up whitespace)
    format = M.organize_imports,
    sources = function(buf)
      local clients = get_clients(buf)
      return vim.tbl_map(function(client) return client.name end, clients)
    end,
  }
  return vim.tbl_extend("force", ret, opts or {})
end

return M
