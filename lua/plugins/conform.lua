---Taken from `prettier -h`
local prettier_parsers = vim.tbl_flatten({
  { "flow", "babel", "babel-flow", "babel-ts", "typescript", "acorn", "espree", "meriyah", "css", "less" },
  { "scss", "json", "json5", "jsonc", "json-stringify", "graphql", "markdown", "mdx" },
  { "vue", "yaml", "glimmer", "html", "angular", "lwc" },
})
---vim file types that don't directly map to prettier parser names
local prettier_ft_overrides = {
  javascriptreact = "typescript",
  javascript = "typescript",
  typescriptreact = "typescript",
  ["markdown.mdx"] = "mdx",
}

---@type LazySpec
return {
  "stevearc/conform.nvim",
  optional = true,
  opts = {
    formatters = {
      -- Pass the --parser argument to prettier
      ---@type conform.FormatterConfigOverride
      prettier = {
        prepend_args = function(_self, ctx)
          local ft = vim.bo[ctx.buf].filetype
          ft = prettier_ft_overrides[ft] or ft
          -- If prettier doesn't support this language, take our chances with auto detection
          if not vim.tbl_contains(prettier_parsers, ft) then return {} end
          return { "--parser", ft }
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
