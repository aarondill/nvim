vim.diagnostic.config({
  underline = true,
  update_in_insert = false,
  virtual_text = {
    spacing = 4,
    source = "if_many",
    prefix = "●",
    -- -- Return the icon corresponding to the severity
    -- prefix = vim.fn.has("nvim-0.10.0") == 0 and "●" or function(diagnostic) ---@param diagnostic vim.Diagnostic
    --   local icons = require("config.icons").lazyvim.icons.diagnostics
    --   local severity_str = vim.diagnostic.severity[diagnostic.severity]
    --   for d, icon in pairs(icons) do
    --     if severity_str == d:upper() then return icon end
    --   end
    -- end,
  },
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = require("config.icons").lazyvim.icons.diagnostics.Error,
      [vim.diagnostic.severity.WARN] = require("config.icons").lazyvim.icons.diagnostics.Warn,
      [vim.diagnostic.severity.HINT] = require("config.icons").lazyvim.icons.diagnostics.Hint,
      [vim.diagnostic.severity.INFO] = require("config.icons").lazyvim.icons.diagnostics.Info,
    },
  },
})
