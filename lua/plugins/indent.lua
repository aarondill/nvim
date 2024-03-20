local create_autocmd = require("utils.create_autocmd")
return {
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    opts = {
      indent = {
        char = "│",
        tab_char = "│",
      },
      scope = { enabled = false },
      exclude = {
        filetypes = require("consts").ignored_filetypes,
      },
    },
    main = "ibl",
  },
  { -- highligh current scope
    "echasnovski/mini.indentscope",
    version = false,
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    opts = {
      symbol = "│",
      options = { try_as_border = true },
    },
    init = function()
      create_autocmd(
        "FileType",
        function() vim.b.miniindentscope_disable = true end,
        { pattern = require("consts").ignored_filetypes }
      )
    end,
  },
}
