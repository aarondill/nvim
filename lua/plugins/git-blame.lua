local cmd = require("utils.flatten")(
  { "GitBlameOpenCommitURL", "GitBlameToggle", "GitBlameEnable", "GitBlameDisable" },
  { "GitBlameCopySHA", "GitBlameCopyCommitURL", "GitBlameOpenFileURL", "GitBlameCopyFileURL" }
)
---@type LazySpec
return {
  "f-person/git-blame.nvim",
  ---@type SetupOptions
  opts = {
    message_when_not_committed = "No commit.",
    date_format = "%r",
    ignored_filetypes = require("consts").ignored_filetypes,
    delay = 1000, -- 1 second
  },
  event = "LazyFile",
  cmd = cmd,
}
