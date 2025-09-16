---@type LazySpec
return {
  "folke/noice.nvim",
  event = "VeryLazy",
  ---@type NoiceConfig
  opts = {
    lsp = {
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
    },
    routes = {
      {
        filter = {
          event = "msg_show",
          any = {
            { find = "%d+L, %d+B" },
            { find = "; after #%d+" },
            { find = "; before #%d+" },
          },
        },
        view = "mini",
      },
    },
    presets = {
      bottom_search = true,
      command_palette = true,
      long_message_to_split = true,
      inc_rename = true,
    },
    markdown = {
      hover = {
        ["|(%S-)|"] = vim.cmd.help, -- vim help links
        ["%[.-%]%((%S-)%)"] = function(uri) -- markdown links
          local open = require("utils").open
          if vim.startswith(uri, "jdt://") then
            -- If the url is a jdt file, open it in a new tab
            -- note: jdtls will handle the url properly and open the documentation
            return open(uri)
          elseif vim.startswith(uri, "file://") then
            local file = vim.uri_to_fname(uri)
            return open(file)
          elseif not uri:match("^.*://") then
            -- This "uri" doesn't have a scheme, so it's probably a filepath
            return open(uri)
          end
          return require("lazy.util").open(uri)
        end,
      },
    },
  },
  keys = {
    { "<leader>snl", function() require("noice").cmd("last") end, desc = "Noice Last Message" },
    { "<leader>snh", function() require("noice").cmd("history") end, desc = "Noice History" },
    { "<leader>sna", function() require("noice").cmd("all") end, desc = "Noice All" },
    { "<leader>snd", function() require("noice").cmd("dismiss") end, desc = "Dismiss All" },
    {
      "<c-f>",
      function()
        if not require("noice.lsp").scroll(4) then return "<c-f>" end
      end,
      silent = true,
      expr = true,
      desc = "Scroll forward",
      mode = { "i", "n", "s" },
    },
    {
      "<c-b>",
      function()
        if not require("noice.lsp").scroll(-4) then return "<c-b>" end
      end,
      silent = true,
      expr = true,
      desc = "Scroll backward",
      mode = { "i", "n", "s" },
    },
  },
}
