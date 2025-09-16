local create_autocmd = require("utils.create_autocmd")
-- lsp symbol navigation for lualine. This shows where
-- in the code structure you are - within functions, classes,
-- etc - in the statusline.
---@type LazySpec
return {
  "SmiteshP/nvim-navic",
  lazy = true,
  init = function()
    vim.g.navic_silence = true
    create_autocmd("LspAttach", function(args)
      local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
      if not client:supports_method("textDocument/documentSymbol") then return end
      return require("nvim-navic").attach(client, args.buf)
    end)
  end,
  opts = {
    separator = " ",
    highlight = true,
    depth_limit = 5,
    icons = require("config.icons").kinds,
    lazy_update_context = true,
  },
}
