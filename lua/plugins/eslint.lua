if true then return {} end
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = { ---@type lspconfig.options|{}
      eslint = {
        settings = { ---@type lspconfig.settings.eslint|{}
          -- helps eslint find the eslintrc when it's placed in a subfolder instead of the cwd root
          workingDirectories = { mode = "auto" },
        },
      },
    },
    setup = {
      eslint = function()
        local function get_client(buf) return vim.lsp.get_clients({ name = "eslint", bufnr = buf })[1] end

        local formatter = require("plugins.lsp.formatter").formatter({
          name = "eslint: lsp",
          primary = false,
          priority = 200,
          filter = "eslint",
        })

        -- Use EslintFixAll on Neovim < 0.10.0
        if not pcall(require, "vim.lsp._dynamic") then
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
        require("util.format").register(formatter)
      end,
    },
  },
}
