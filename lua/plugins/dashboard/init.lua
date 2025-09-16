local t = require("utils").telescope
math.randomseed(os.time())
for _ = 1, 10 do
  math.random()
end
---@type LazySpec
return {
  "nvimdev/dashboard-nvim",
  event = { "VimEnter", "StdinReadPre" },
  opts = function()
    local headers = require("plugins.dashboard.headers")
    local header = headers[math.random(1, #headers)]
    while #header < 20 do
      table.insert(header, 1, "")
      table.insert(header, "")
    end

    local opts = {
      theme = "doom",
      hide = {
        -- this is taken care of by lualine
        -- enabling this messes up the actual laststatus setting after loading a file
        statusline = false,
      },
      config = {
        header = header,
        center = {
          {
            action = t("find_files"),
            desc = " Find file",
            icon = " ",
            key = "f",
          },
          {
            action = "ene | startinsert",
            desc = " New file",
            icon = " ",
            key = "n",
          },
          {
            action = t("oldfiles"),
            desc = " Recent files",
            icon = " ",
            key = "r",
          },
          {
            action = t("live_grep"),
            desc = " Find text",
            icon = " ",
            key = "g",
          },
          {
            action = 'lua require("persistence").load()',
            desc = " Restore Session",
            icon = " ",
            key = "s",
          },
          {
            action = "Lazy",
            desc = " Lazy",
            icon = "󰒲 ",
            key = "l",
          },
          {
            action = "qa",
            desc = " Quit",
            icon = " ",
            key = "q",
          },
        },
        footer = function()
          local stats = require("lazy").stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          return { "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
        end,
      },
    }

    -- Space out the keys
    for _, button in ipairs(opts.config.center) do
      button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
      button.key_format = "  %s"
    end

    return opts
  end,
}
