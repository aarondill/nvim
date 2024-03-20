local create_autocmd = require("utils.create_autocmd")
local map = require("utils.map")
-- Automatically highlights other instances of the word under your cursor.
-- This works with LSP, Treesitter, and regexp matching to find the other
-- instances.
return {
  "RRethy/vim-illuminate",
  event = { "BufReadPost", "BufNewFile", "BufWritePre" },
  opts = {
    delay = 200,
    large_file_cutoff = 2000,
    large_file_overrides = { providers = { "lsp" } },
  },
  config = function(_, opts)
    require("illuminate").configure(opts)

    map("n", "]]", require("illuminate").goto_next_reference, "Next Reference")
    map("n", "]]", require("illuminate").goto_prev_reference, "Prev Reference")
    create_autocmd("FileType", function(ev) -- A lot of ft plugins overwrite [[ and ]]
      map("n", "]]", require("illuminate").goto_next_reference, "Next Reference", { buffer = ev.buf })
      map("n", "]]", require("illuminate").goto_prev_reference, "Prev Reference", { buffer = ev.buf })
    end)
  end,
  keys = {
    { "]]", desc = "Next Reference" },
    { "[[", desc = "Prev Reference" },
  },
}
