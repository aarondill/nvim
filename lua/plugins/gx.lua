---@type LazySpec
return {
  "chrishrb/gx.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = { "Browse" },
  init = function()
    vim.g.netrw_nogx = 1 -- disable netrw gx
  end,
  opts = {
    select_for_search = false,
  },
  keys = {
    { "gx", "<cmd>Browse<cr>", mode = { "n", "x" } },
    {
      "gf",
      function()
        local cursor_file = require("utils").vtext() or vim.fn.expand("<cfile>")
        if not cursor_file:match("^https?://") then return "gf" end
        -- Found a url. Use gx to open it!
        return "gx"
      end,
      mode = { "n", "x" },
      remap = true,
      expr = true,
    },
  },
  config = true,
}
