return {
  { -- add json to treesitter
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) ~= "table" then return end
      vim.list_extend(opts.ensure_installed, { "json", "json5", "jsonc" })
    end,
  },
  { -- yaml schema support
    "b0o/SchemaStore.nvim",
    version = false,
  },
  { -- correctly setup lspconfig
    "neovim/nvim-lspconfig",
    opts = {
      servers = { -- make sure mason installs the server
        jsonls = {
          on_new_config = function(new_config) -- lazy-load schemastore when needed
            new_config.settings.json.schemas = new_config.settings.json.schemas or {}
            vim.list_extend(new_config.settings.json.schemas, require("schemastore").json.schemas())
          end,
          settings = { json = { format = { enable = true }, validate = { enable = true } } },
        },
      },
    },
  },
}
