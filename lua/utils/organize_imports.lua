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
  -- Source: https://github.com/mrcjkb/rustaceanvim/issues/259#issuecomment-2674029681
  -- Needed until https://github.com/rust-lang/rust-analyzer/issues/5131 is merged
  ["rust_analyzer"] = function(client, bufnr)
    local last_line = vim.api.nvim_buf_get_lines(bufnr, -2, -1, false)[1]
    if not last_line then return end -- if there's no lines, there's no point in organizing.
    local params = vim.lsp.util.make_given_range_params( -- full file
      { 1, 0 },
      { vim.api.nvim_buf_line_count(bufnr), #last_line - 1 },
      bufnr,
      "utf-16"
    )
    ---@diagnostic disable-next-line: inject-field -- it's wrong
    params.context =
      { diagnostics = {}, only = { "quickfix" }, triggerKind = vim.lsp.protocol.CodeActionTriggerKind.Invoked }

    local actions = client:request_sync("textDocument/codeAction", params, 1000, bufnr)
    if not actions or actions.err then return end -- don't log error, the use will probably (need to) try again laster
    local action = vim.iter(actions.result):find(function(a) return a.title == "Remove all unused imports" end) --- @type lsp.CodeAction[]
    if not action then return end

    local resolve = assert(client:request_sync("codeAction/resolve", action, 1000, bufnr))
    if resolve.err then return error(resolve.err.code .. ": " .. resolve.err.message) end
    if resolve.result.edit then vim.lsp.util.apply_workspace_edit(resolve.result.edit, client.offset_encoding) end

    -- client:request("textDocument/codeAction", params, function(err, result) --- @param result? lsp.CodeAction[]
    --   if err then error(err.code .. ": " .. err.message) end
    --   if not result then return end
    --   local action = vim.iter(result):find(function(a) return a.title == "Remove all unused imports" end) --- @type lsp.CodeAction[]
    --   if not action then return end
    --   client:request("codeAction/resolve", action, function(err_resolve, resolved_action)
    --     if err_resolve then error(err_resolve.code .. ": " .. err_resolve.message) end
    --     if resolved_action.edit then vim.lsp.util.apply_workspace_edit(resolved_action.edit, client.offset_encoding) end
    --   end, bufnr)
    -- end, bufnr)
  end,
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
    function(client)
      return client:supports_method("workspace/executeCommand", bufnr)
        or type(M.server_commands[client.name]) == "function"
    end,
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
      if not client:supports_method("workspace/executeCommand", bufnr) then
        error(("client %s does not support workspace/executeCommand"):format(client.name))
      end
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
