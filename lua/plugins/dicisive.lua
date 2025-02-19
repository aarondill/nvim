local create_autocmd = require("utils.create_autocmd")
local map = require("utils.map")
---@type LazySpec
return {
  "emmanueltouzery/decisive.nvim",
  opts = {},
  lazy = true,
  init = function()
    create_autocmd(
      "FileType",
      vim.schedule_wrap(function(ev) ---@param ev EventInfo
        local ft, buf = ev.match, ev.buf
        if ft ~= "csv" and ft ~= "tsv" then -- none-csv filetypes, don't align
          if not vim.b._activated_descive then return end -- don't import if not needed
          vim.b._activated_descive = nil
          return vim.api.nvim_buf_call(buf, function() -- this clears the "current" buffer
            return require("decisive").align_csv_clear()
          end)
        end
        local max_filesize = 1000 * 1024 -- 1 MB
        local ok, stats = pcall(vim.uv.fs_stat, ev.file)
        if ok and stats and stats.size > max_filesize then return end

        vim.schedule(function()
          if vim.b._activated_descive then return end -- already ran
          vim.b._activated_descive = true
          local decisive = require("decisive")
          map("n", "[c", function() return decisive.align_csv_prev_col() end, "prev col", { buffer = buf })
          map("n", "]c", function() return decisive.align_csv_next_col() end, "next col", { buffer = buf })
          return vim.api.nvim_buf_call(buf, function() --
            return decisive.align_csv({ auto_realign_limit_ms = 5 * 1000, print_speed = true })
          end)
        end)
      end),
      "Auto align csv"
    )
  end,
  config = true,
  ft = { "csv", "tsv" },
}
