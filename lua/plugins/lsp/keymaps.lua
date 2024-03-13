local map = require("utils.set_key_map")
local M = {}

---@param buffer integer
---@param method string
local function has(buffer, method)
  method = method:find("/") and method or "textDocument/" .. method
  local clients = vim.lsp.get_clients({ bufnr = buffer })
  for _, client in ipairs(clients) do
    if client.supports_method(method, { bufnr = buffer }) then return true end
  end
  return false
end

---@param client integer|vim.lsp.Client
---@param buffer? integer
function M.apply(client, buffer)
  if type(client) == "number" then client = assert(vim.lsp.get_client_by_id(client)) end
  buffer = buffer or vim.api.nvim_get_current_buf()
  --- Apply universal lsp remaps here

  map("n", "<leader>cl", "<cmd>LspInfo<cr>", "Lsp Info", { buffer = buffer })
  if has(buffer, "definition") then
    map("n", "gd", function() --
      return require("telescope.builtin").lsp_definitions({ reuse_win = true })
    end, "Goto Definition", { buffer = buffer })
  end
  map("n", "gr", "<cmd>Telescope lsp_references<cr>", "References")
  map("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
  map("n", "gI", function() --
    return require("telescope.builtin").lsp_implementations({ reuse_win = true })
  end, "Goto Implementation")
  map("n", "gy", function() --
    return require("telescope.builtin").lsp_type_definitions({ reuse_win = true })
  end, "Goto T[y]pe Definition")
  map("n", "K", vim.lsp.buf.hover, "Hover")
  if has(buffer, "signatureHelp") then
    map("n", "gK", vim.lsp.buf.signature_help, "Signature Help")
    -- map("i", "<c-k>", vim.lsp.buf.signature_help, "Signature Help")
  end
  if has(buffer, "codeAction") then
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
    local source_action = function()
      return vim.lsp.buf.code_action({ context = { only = { "source" }, diagnostics = {} } })
    end
    map("n", "<leader>cA", source_action, "Source Action")
  end
  if has(buffer, "codeLens") then
    map({ "n", "v" }, "<leader>cc", vim.lsp.codelens.run, "Run Codelens")
    map("n", "<leader>cC", vim.lsp.codelens.refresh, "Refresh & Display Codelens")
  end
  if has(buffer, "rename") then
    local f, expr = vim.lsp.buf.rename, false
    if require("lazy.core.config").spec.plugins["inc-rename.nvim"] then -- we have inc-rename
      f = function() return (":%s %s"):format(require("inc_rename").config.cmd_name, vim.fn.expand("<cword>")) end
      expr = true
    end
    map("n", { "<leader>cr", "<f2>" }, f, "Rename", { expr = expr })
  end
end

return M
