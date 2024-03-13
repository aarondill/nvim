return {
  "stevearc/conform.nvim",
  optional = true,
  opts = {
    formatters = {
      -- Pass the --parser argument to prettier
      ---@type conform.FormatterConfigOverride
      prettier = {
        prepend_args = function(_self, ctx)
          local overrides = { -- vim file types that don't directly map to prettier parser names
            javascriptreact = "javascript",
            typescriptreact = "typescript",
            ["markdown.mdx"] = "mdx",
          }
          local ft = vim.bo[ctx.buf].filetype
          local parser = overrides[ft] or ft
          if parser == "" then return {} end
          return { "--parser", parser }
        end,
      },
      -- Set stylua to use the current shift width
      ---@type conform.FormatterConfigOverride
      stylua = {
        prepend_args = function(_self, ctx)
          local bufutils = require("utils.buf")
          local i = bufutils.get_indent(ctx.buf)
          if i.tabs then return { "--indent-type", "Tabs" } end
          return {
            "--indent-width",
            i.size,
            "--indent-type",
            "Spaces",
          }
        end,
      },

      -- Set shfmt to use the current shift width
      ---@type conform.FormatterConfigOverride
      shfmt = {
        prepend_args = function(_self, ctx)
          local bufutils = require("utils.buf")
          local i = bufutils.get_indent(ctx.buf)
          return { "-i", i.tabs and 0 or i.size }
        end,
      },
    },
  },
}
