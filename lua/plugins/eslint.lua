local create_autocmd = require("utils.create_autocmd")
-- if true then return {} end

create_autocmd("LspAttach", function(ev)
  do
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client or client.name ~= "eslint" then return end
  end

  local function get_client(buf) return vim.lsp.get_clients({ name = "eslint", bufnr = buf })[1] end

  local formatter = require("plugins.lsp.formatter").formatter({
    name = "Eslint: LSP",
    primary = false,
    priority = 200,
    filter = "eslint",
  })

  -- Use EslintFixAll on Neovim < 0.10.0
  if vim.fn.has("nvim-0.10.0") == 0 then
    formatter.name = "eslint: EslintFixAll"
    formatter.sources = function(buf) return get_client(buf) and { "eslint" } or {} end
    formatter.format = function(buf)
      local client = get_client(buf)
      if not client then return end
      local diag = vim.diagnostic.get(buf, { namespace = vim.lsp.diagnostic.get_namespace(client.id) })
      if #diag > 0 then vim.cmd("EslintFixAll") end
    end
  end

  -- register the formatter
  require("utils.format").register(formatter)
end)

vim.lsp.config("eslint", { ---@type vim.lsp.Config
  settings = {
    eslint = { -- helps eslint find the eslintrc when it's placed in a subfolder instead of the cwd root
      workingDirectories = { mode = "auto" },
    },
  },
})

return {
  "williamboman/mason.nvim",
  optional = true,
  opts = {
    ensure_installed = { "eslint-lsp" },
  },
}
