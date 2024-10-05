local M = {}

---Loads all matches to the quickfix list then opens a telescope picker
---@param result lsp.TypeHierarchyItem[]|nil
---@param ctx {params: {item: lsp.TypeHierarchyItem}}
function M.telescope_hierarchy(_, result, ctx)
  if not result then return end
  table.insert(result, 1, ctx.params.item) -- insert the given item at the start of the list
  vim.ui.select(result, {
    ---@return string
    format_item = function(item) ---@param item lsp.TypeHierarchyItem
      local kind = vim.lsp.protocol.SymbolKind[item.kind] or "Unknown"
      return item.name .. " [" .. kind .. "]"
    end,
    prompt = "Select to open:",
  }, function(item) ---@param item lsp.TypeHierarchyItem?
    if not item then return end -- ensure no nil index
    item.range = item.selectionRange -- We prefer to jump at the selectionRange
    vim.lsp.util.jump_to_location(item, "utf-8", true)
  end)
end

function M.type_hierarchy(method, handler)
  local params = vim.lsp.util.make_position_params()
  local prepare_method = "textDocument/prepareTypeHierarchy"
  vim.lsp.buf_request(0, prepare_method, params, function(_, result)
    if not result then return end
    vim.lsp.buf_request(0, method, { item = result[1] }, handler)
  end)
end

return M
