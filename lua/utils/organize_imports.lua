---@alias organize_imports_command string|fun(self: vim.lsp.Client, bufnr: integer):string?

---Mapping of lsp names (vim.lsp.get_clients) to commands. Special name
---`default` is used if no key is found. If function, it is called and may
---optionally return a string. If a string, passed as an argument to
---`vim.lsp.buf_request_sync` with method `workspace/executeCommand`
---@type table<string, organize_imports_command>
local commands = {
  default = "source.organizeImports",
  ["ts_ls"] = "_typescript.organizeImports",
  ["jdtls"] = function() return require("jdtls").organize_imports() end,
}

return function()
  local method = "workspace/executeCommand"
  local bufnr = vim.api.nvim_get_current_buf()
  local client = vim.lsp.get_clients({ bufnr = bufnr })[1]
  ---@type organize_imports_command?
  local command = commands[client.name] or commands.default
  if type(command) == "function" then command = command(client, bufnr) end
  if not command then return end -- No command found / function returned nil

  if not client.supports_method(method, { bufnr = bufnr }) then return end -- This client does not support the workspace/executeCommand method
  client.request_sync(method, { command = command, arguments = { vim.api.nvim_buf_get_name(bufnr) } }, nil, bufnr)
end
