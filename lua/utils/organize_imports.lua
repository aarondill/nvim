return function()
  local bufnr = vim.api.nvim_get_current_buf()
  local method = "workspace/executeCommand"

  local tsserver_is_attached = next(vim.lsp.get_clients({ bufnr = bufnr, name = "tsserver" })) ~= nil
  local command = tsserver_is_attached and "_typescript.organizeImports" or "source.organizeImports"

  if not tsserver_is_attached then
    local supports = false
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
      if client.supports_method(method, { bufnr = bufnr }) then
        supports = true
        break
      end
    end
    if not supports then return end -- This client does not support the workspace/executeCommand method
  end

  vim.lsp.buf_request_sync(bufnr, method, { command = command, arguments = { vim.api.nvim_buf_get_name(bufnr) } })
end
