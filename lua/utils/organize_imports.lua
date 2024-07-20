return function()
  local tsserver_is_attached = next(vim.lsp.get_clients({ bufnr = 0, name = "tsserver" })) ~= nil
  vim.lsp.buf_request_sync(0, "workspace/executeCommand", {
    command = tsserver_is_attached and "_typescript.organizeImports" or "source.organizeImports",
    arguments = { vim.api.nvim_buf_get_name(0) },
  })
end
