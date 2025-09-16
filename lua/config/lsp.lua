vim.diagnostic.config({
  underline = true,
  update_in_insert = false,
  virtual_text = {
    spacing = 4,
    source = "if_many",
    prefix = "●",
    -- -- Return the icon corresponding to the severity
    -- prefix = vim.fn.has("nvim-0.10.0") == 0 and "●" or function(diagnostic) ---@param diagnostic vim.Diagnostic
    --   local icons = require("config.icons").diagnostics
    --   local severity_str = vim.diagnostic.severity[diagnostic.severity]
    --   for d, icon in pairs(icons) do
    --     if severity_str == d:upper() then return icon end
    --   end
    -- end,
  },
  float = {
    prefix = "",
    suffix = "",
    format = function(d)
      if not d.code then return d.message end
      return string.format("%s (%s)", d.message, d.code)
    end,
    source = true,
  },
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = require("config.icons").diagnostics.Error,
      [vim.diagnostic.severity.WARN] = require("config.icons").diagnostics.Warn,
      [vim.diagnostic.severity.HINT] = require("config.icons").diagnostics.Hint,
      [vim.diagnostic.severity.INFO] = require("config.icons").diagnostics.Info,
    },
  },
})

---Ignored diagnostic codes per source
---TODO: Move to a config file
---@type {[string]?: (string|number)[] }
local ignored_diagnostics = {
  ["typescript"] = {
    -- codes: https://github.com/microsoft/TypeScript/blob/main/src/compiler/diagnosticMessages.json
    80006, -- "This may be converted to an async function."
  },
  --- Use to ignore diagnostics that don't report a source
  [""] = {},
}

---@param diagnostics lsp.Diagnostic[]
local function filter_diagnostics(diagnostics)
  if diagnostics == nil then return end
  return vim
    .iter(diagnostics)
    :filter(function(d) ---@param d lsp.Diagnostic
      local ignored = ignored_diagnostics[d.source or ""]
      if not ignored then return true end
      return not vim.tbl_contains(ignored, d.code)
    end)
    :totable() ---@type lsp.Diagnostic[]
end

---Filter diagnostics when received from the server
---NOTE: This can affect Code Actions, if they depend on a diagnostic
vim.lsp.handlers["textDocument/publishDiagnostics"] = function(_, result, ctx, config)
  if result.diagnostics == nil then return end
  result.diagnostics = filter_diagnostics(result.diagnostics)
  vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
end

-- local function create_filtered_diagnostic_handler(old)
--   assert(old, "old diagnostic handler is nil")
--   return { ---@type vim.diagnostic.Handler
--     show = function(ns, bufnr, diagnostics, ...) ----
--       return old.show(ns, bufnr, filter_diagnostics(diagnostics), ...)
--     end,
--     hide = old.hide,
--   }
-- end
-- vim.diagnostic.handlers.virtual_text = create_filtered_diagnostic_handler(vim.diagnostic.handlers.virtual_text)
-- vim.diagnostic.handlers.underline = create_filtered_diagnostic_handler(vim.diagnostic.handlers.underline)
-- vim.diagnostic.handlers.signs = create_filtered_diagnostic_handler(vim.diagnostic.handlers.signs)
