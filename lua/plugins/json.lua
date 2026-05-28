---@type vim.lsp.Config
local o = {
  before_init = function(params, config)
    vim.tbl_deep_extend("keep", config, { settings = { json = { schemas = {} } } })
    config.settings.json.schemas =
      vim.list_extend(config.settings.json.schemas or {}, require("schemastore").json.schemas())
  end,
  settings = {
    json = {
      format = { enable = true },
      validate = { enable = true },
    },
  },
}
vim.lsp.config("jsonls", o)

---@type LazySpec
return { -- yaml schema support
  "b0o/SchemaStore.nvim",
  version = false,
}
