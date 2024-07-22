return function()
  local bufnr = vim.api.nvim_get_current_buf()
  local method = "workspace/executeCommand"

  local tsserver_is_attached = next(vim.lsp.get_clients({ bufnr = bufnr, name = "tsserver" })) ~= nil
  local command = tsserver_is_attached and "_typescript.organizeImports" or "source.organizeImports"

  local supports = tsserver_is_attached
    or next(vim.lsp.get_clients({ bufnr = bufnr, method = "workspace/executeCommand" })) ~= nil
  if not supports then return end -- This client does not support the workspace/executeCommand method

  vim.lsp.buf_request_sync(bufnr, method, { command = command, arguments = { vim.api.nvim_buf_get_name(bufnr) } })
end
