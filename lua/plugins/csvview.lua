local create_autocmd = require("utils.create_autocmd")
---@type LazySpec
return {
  "hat0uma/csvview.nvim",
  ---@module "csvview"
  ---@type CsvView.Options
  opts = {
    parser = { comments = { "#", "//" } },
    keymaps = {
      -- Text objects for selecting fields
      textobject_field_inner = { "if", mode = { "o", "x" } },
      textobject_field_outer = { "af", mode = { "o", "x" } },
      -- Use <Tab> and <S-Tab> to move horizontally between fields.
      -- Use <Enter> and <S-Enter> to move vertically between rows.
      jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
      jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
      jump_next_row = { "<Enter>", mode = { "n", "v" } },
      jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
    },
  },
  init = function()
    create_autocmd("FileType", function(ev)
      if not vim.api.nvim_buf_is_valid(ev.buf) then return end
      return require("csvview").enable(ev.buf)
    end, "Enable csvview", { pattern = { "csv", "tsv" } })
    vim.api.nvim_set_hl(0, "CsvViewDelimiter", { fg = "#Fb4b4b" })
  end,
  ft = { "csv", "tsv" },
  cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
}
