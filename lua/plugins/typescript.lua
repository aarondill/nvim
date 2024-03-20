local create_autocmd = require("utils.create_autocmd")
local filetypes = { "html", "typescript", "javascript", "typescriptreact", "javascriptreact", "python" } -- filetypes where the plugin is active
---@type LazySpec
return {
  {
    "https://github.com/axelvc/template-string.nvim",
    ft = filetypes, -- lazy load it
    opts = {
      filetypes = filetypes,
      jsx_brackets = true, -- must add brackets to JSX attributes
      remove_template_string = false, -- remove backticks when there are no template strings
    },
  },
  {
    "marilari88/twoslash-queries.nvim",
    lazy = true,
    opts = {
      multi_line = true, -- to print types in multi line mode
      is_enabled = true, -- to keep disabled at startup and enable it on request with the TwoslashQueriesEnable
      highlight = "Constant", -- to set up a highlight group for the virtual text
    },
    ft = "typescript",
    cmd = {
      "TwoslashQueriesEnable",
      "TwoslashQueriesDisable",
      "TwoslashQueriesInspect",
      "TwoslashQueriesRemove",
    },
    init = function()
      create_autocmd("LspAttach", function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client or not client.name then return end
        if client.name ~= "tsserver" then return end
        return require("twoslash-queries").attach(client, args.buf)
      end)
    end,
  },
  { -- add typescript to treesitter
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then vim.list_extend(opts.ensure_installed, { "typescript", "tsx" }) end
    end,
  },
}
