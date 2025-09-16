---@type LazySpec
return {
  "akinsho/bufferline.nvim",
  event = "VeryLazy",
  opts = { ---@type bufferline.UserConfig
    options = {
      close_command = function(n) require("mini.bufremove").delete(n, false) end,
      right_mouse_command = function(n) require("mini.bufremove").delete(n, false) end,
      diagnostics = "nvim_lsp",
      always_show_bufferline = false,
      diagnostics_indicator = function(_, _, diag)
        local icons = require("config.icons").diagnostics
        local ret = {}
        if diag.error then ret[#ret + 1] = icons.Error .. diag.error end
        if diag.warning then ret[#ret + 1] = icons.Warn .. diag.warning end
        return table.concat(ret, " ")
      end,
      offsets = {
        {
          filetype = "neo-tree",
          text = "Neo-tree",
          highlight = "Directory",
          text_align = "left",
        },
      },
    },
  },
  config = function(_, opts)
    require("bufferline").setup(opts)
    -- Fix bufferline when restoring a session
    vim.api.nvim_create_autocmd("BufAdd", {
      callback = vim.schedule_wrap(function() return pcall(nvim_bufferline) end),
    })
  end,
}
