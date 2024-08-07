---@type LazySpec
return {
  "folke/todo-comments.nvim",
  cmd = { "TodoTrouble", "TodoTelescope" },
  event = "LazyFile",
  opts = {
    keywords = {
      -- FIX: This note
      FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
      -- TODO: This note
      TODO = { icon = " ", color = "info", alt = { "WIP" } },
      -- HACK: This note
      HACK = { icon = " ", color = "warning", alt = { "DEV" } },
      -- WARN: This note
      WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
      -- PERF: This note
      PERF = { icon = "󰅒 ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
      -- NOTE: This note
      NOTE = { icon = "󰍩 ", color = "hint", alt = { "INFO", "HINT" } },
      -- TEST(hello): This note
      TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
    },
    -- list of highlight groups or use the hex color if hl not found as a fallback
    highlight = {
      after = "",
      keyword = "bg",
      multiline = false,
      pattern = [[.*<((KEYWORDS)\s*([^:]*)?\s*:)]],
    },
  },
  keys = {
    { "]t", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
    { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
    { "<leader>st", "<cmd>TodoTelescope<cr>", desc = "Todo" },
    { "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme" },
  },
}
