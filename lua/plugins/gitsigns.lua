-- git signs highlights text that has changed since the list
-- git commit, and also lets you interactively stage & unstage
-- hunks in a commit.
return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPost", "BufNewFile", "BufWritePre" },
  opts = { ---@type Gitsigns.Config | {}
    attach_to_untracked = true,
    on_attach = function(buffer)
      local map, gs = require("utils.map"), require("gitsigns")

      map("n", "]h", gs.next_hunk, "Next Hunk", { buffer = buffer })
      map("n", "[h", gs.prev_hunk, "Prev Hunk", { buffer = buffer })
      map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk", { buffer = buffer })
      map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk", { buffer = buffer })
      map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer", { buffer = buffer })
      map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk", { buffer = buffer })
      map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer", { buffer = buffer })
      map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline", { buffer = buffer })
      map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line", { buffer = buffer })
      map("n", "<leader>ghd", gs.diffthis, "Diff This", { buffer = buffer })
      map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~", { buffer = buffer })
      map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk", { buffer = buffer })
    end,
  },
}
