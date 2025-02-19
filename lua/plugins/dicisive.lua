local create_autocmd = require("utils.create_autocmd")
local map = require("utils.map")
require("utils.pr_merged").on_lazy("emmanueltouzery/decisive.nvim", 8)

---@type LazySpec
return {
  "aarondill/decisive.nvim",
  opts = {},
  lazy = true,
  init = function()
    create_autocmd(
      "FileType",
      vim.schedule_wrap(function(ev) ---@param ev EventInfo
        local ft, buf = ev.match, ev.buf
        if not vim.api.nvim_buf_is_valid(buf) then return end
        if ft ~= "csv" and ft ~= "tsv" then -- none-csv filetypes, don't align
          if not vim.b[buf]._activated_descive then return end -- don't import if not needed
          vim.b[buf]._activated_descive = nil
          return require("decisive").align_csv_clear({ bufnr = buf })
        end
        local max_filesize = 1000 * 1024 -- 1 MB
        local ok, stats = pcall(vim.uv.fs_stat, ev.file)
        if ok and stats and stats.size > max_filesize then return end

        vim.schedule(function()
          if vim.b[buf]._activated_descive then return end -- already ran
          vim.b[buf]._activated_descive = true
          local decisive = require("decisive")
          map("n", "[c", function() return decisive.align_csv_prev_col() end, "prev col", { buffer = buf })
          map("n", "]c", function() return decisive.align_csv_next_col() end, "next col", { buffer = buf })
          return decisive.align_csv({ auto_realign_limit_ms = 5 * 1000, print_speed = true, bufnr = buf })
        end)
      end),
      "Auto align csv"
    )
  end,
  config = true,
  ft = { "csv", "tsv" },
}
