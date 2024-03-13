local map = require("utils.map")
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
local function has_plugin(p) return require("lazy.core.config").spec.plugins[p] ~= nil end

---@param client integer|vim.lsp.Client
---@param buffer? integer
function M.apply(client, buffer)
  if type(client) == "number" then client = assert(vim.lsp.get_client_by_id(client)) end
  buffer = buffer or vim.api.nvim_get_current_buf()
  --- Apply universal lsp remaps here
  local cap = client.server_capabilities or {}
  local function telescope_builtin(key)
    return function() return require("telescope.builtin")[key]({ reuse_win = true }) end
  end
  local source_action = function()
    return vim.lsp.buf.code_action({ context = { only = { "source" }, diagnostics = {} } })
  end

  local rename_rhs, rename_is_expr = vim.lsp.buf.rename, false
  if has_plugin("inc-rename.nvim") then -- we have inc-rename
    rename_rhs = function() return (":%s %s"):format(require("inc_rename").config.cmd_name, vim.fn.expand("<cword>")) end
    rename_is_expr = true
  end

  ---@type ({mode?:string[]|string,[1]: string|string[], [2]: string|fun():any?, desc:string, cond: any})[]
  local keys = {
    { "<leader>cl", "<cmd>LspInfo<cr>", desc = "Lsp Info" },
    {
      "gd",
      telescope_builtin("lsp_definitions"),
      desc = "Goto Definition",
      buffer = buffer,
      cond = cap.definitionProvider,
    },
    { "gD", vim.lsp.buf.declaration, desc = "Goto declaration", cond = cap.declarationProvider },
    { "gr", "<cmd>Telescope lsp_references<cr>", desc = "References", cond = cap.referencesProvider },
    { "gI", telescope_builtin("lsp_implementations"), desc = "Goto Implementation" },
    { "gy", telescope_builtin("lsp_type_definitions"), desc = "Goto T[y]pe Definition" },
    { "K", vim.lsp.buf.hover, desc = "Hover", cond = cap.hoverProvider },
    { "gK", vim.lsp.buf.signature_help, desc = "Signature Help", cond = cap.signatureHelpProvider },
    { "<leader>ca", vim.lsp.buf.code_action, "Code Action", mode = { "n", "v" }, cond = cap.codeActionProvider },
    { "<leader>cA", source_action, "Source Action", cond = cap.codeActionProvider },
    { "<leader>cc", vim.lsp.codelens.run, desc = "Run Codelens", mode = { "n", "v" }, cond = cap.codeLensProvider },
    { "<leader>cC", vim.lsp.codelens.refresh, desc = "Refresh & Display Codelens", cond = cap.codeLensProvider },
    { { "<leader>cr", "<f2>" }, rename_rhs, desc = "Rename", expr = rename_is_expr, cond = cap.renameProvider },
  }

  for _, key in ipairs(keys) do
    local mode, lhs, rhs, cond = key.mode, key[1], key[2], key.cond
    if cond then
      local opts = {}
      for k, v in pairs(key) do
        opts[k] = v
      end
      opts.buffer = buffer
      opts.mode, opts[1], opts[2], opts.cond = nil, nil, nil, nil
      map(mode or "n", lhs, rhs, opts)
    end
  end
end

return M
