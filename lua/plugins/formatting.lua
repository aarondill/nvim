local create_autocmd = require("utils.create_autocmd")

-- use these options when formatting
local format_options = {
  timeout_ms = 3000,
  async = false, -- not recommended to change
  quiet = false, -- not recommended to change
  lsp_fallback = true, -- not recommended to change
}

return {
  "stevearc/conform.nvim",
  dependencies = { "mason.nvim" },
  cmd = "ConformInfo",
  keys = {
    {
      "<leader>cF",
      function() require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 }) end,
      mode = { "n", "v" },
      desc = "Format Injected Langs",
    },
  },
  init = function()
    -- Install the conform formatter on VeryLazy
    create_autocmd("User", function()
      require("utils.format").register({
        name = "conform.nvim",
        priority = 100,
        primary = true,
        format = function(buf)
          local opts = vim.tbl_extend("force", format_options, { bufnr = buf })
          return require("conform").format(opts)
        end,
        sources = function(buf)
          local ret = require("conform").list_formatters(buf)
          return vim.tbl_map(function(v) return v.name end, ret)
        end,
      })
    end, { pattern = "VeryLazy", once = true })
  end,
  ---@class ConformOpts
  opts = {
    formatters_by_ft = { ---@type table<string, conform.FormatterUnit[]>
      lua = { "stylua" },
      fish = { "fish_indent" },
      sh = { "shfmt" },
    },
    -- The options you set here will be merged with the builtin formatters.
    -- You can also define any custom formatters here.
    formatters = { ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer):conform.FormatterConfigOverride?>
      injected = { options = { ignore_errors = true } },
    },
  },
}
