local create_autocmd = require("utils.create_autocmd")
local map = require("utils.map")
create_autocmd("LspAttach", function(ev)
  local function organizeImports()
    vim.lsp.buf.code_action({ apply = true, context = { only = { "source.organizeImports.ts" }, diagnostics = {} } })
  end
  local function removeUnused()
    vim.lsp.buf.code_action({ apply = true, context = { only = { "source.removeUnused.ts" }, diagnostics = {} } })
  end
  map("n", "<leader>co", organizeImports, "Organize Imports", { buffer = ev.buf })
  map("n", "<leader>cR", removeUnused, "Remove Unused Imports", { buffer = ev.buf })
end, {
  once = true, -- we don't need to modify the table more than once
})

return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      tsserver = {
        settings = { ---@type lspconfig.settings.tsserver|{}
          completions = {
            completeFunctionCalls = true,
          },
        },
      },
    },
  },
}
