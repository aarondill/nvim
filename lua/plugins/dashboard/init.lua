if false then _ = require("snacks") end
math.randomseed(os.time())
for _ = 1, 10 do
  math.random()
end
local headers = require("plugins.dashboard.headers")
local lines = headers[math.random(1, #headers)] -- array of lines
local header = vim.iter(lines):join("\n")

return {
  "folke/snacks.nvim",
  event = "VeryLazy",
  ---@type snacks.Config
  opts = {
    dashboard = {
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
        { pane = 2, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1, limit = 8 },
        {
          pane = 2,
          icon = " ",
          title = "Recent Files",
          section = "recent_files",
          indent = 2,
          padding = 1,
          limit = 8,
        },
        function()
          return {
            pane = 2,
            icon = " ",
            desc = "Browse Repo",
            enabled = Snacks.git.get_root() ~= nil,
            padding = 1,
            key = "b",
            action = function() Snacks.gitbrowse() end,
          }
        end,
        function()
          local in_git = Snacks.git.get_root() ~= nil
          local cmds = {
            {
              title = "Open Issues",
              cmd = "gh issue list -L 3",
              key = "i",
              action = function() vim.fn.jobstart("gh issue list --web", { detach = true }) end,
              icon = " ",
              height = 7,
            },
            {
              icon = " ",
              title = "Open PRs",
              cmd = "gh pr list -L 3",
              key = "P",
              action = function() vim.fn.jobstart("gh pr list --web", { detach = true }) end,
              height = 7,
            },
            {
              icon = " ",
              title = "Git Status",
              cmd = "git --no-pager diff --stat -B -M -C",
              height = 10,
            },
          }
          return vim.tbl_map(
            function(cmd)
              return vim.tbl_extend("force", {
                pane = 2,
                section = "terminal",
                enabled = in_git,
                padding = 1,
                ttl = 5 * 60,
                indent = 3,
              }, cmd)
            end,
            cmds
          )
        end,
        { section = "startup" },
      },
      preset = {
        header = header,
      },
    },
  },
}
