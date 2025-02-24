local icons = require("config.icons")
---@param name string
---@return fun(): {fg: string}?
local function getfg(name)
  return function() -- Use a function to allow updating if the hl changes
    local hl
    if vim.api.nvim_get_hl then
      hl = vim.api.nvim_get_hl(0, { name = name, link = false })
    else ---@diagnostic disable-next-line: deprecated
      hl = vim.api.nvim_get_hl_by_name(name, true) ---@type {foreground?:number}?
    end
    local fg = hl and (hl.foreground or hl.fg)
    if not fg then return end
    return { fg = string.format("#%06x", fg) }
  end
end

local function wordcount()
  local wordcount_dict = vim.fn.wordcount()
  local words, chars = wordcount_dict.words, wordcount_dict.chars
  local lines = vim.fn.line("$")
  -- local mins = tostring(math.ceil(words / 200)) -- 200 wpm
  return ("%dw%dc%dl"):format(words, chars, lines)
end
local function time() return icons.clock .. os.date("%R") end

local function _get_current_lsp_for_each_client(client, buf_ft)
  if not vim.lsp.buf_is_attached(0, client.id) then return end
  -- return client.name
  if client.name ~= "null-ls" then return client.name end

  -- Handle NullLS because it doesn't report its sources.
  local null_ls_active_sources = {}
  for _, source in ipairs(require("null-ls.sources").get_available(buf_ft)) do
    table.insert(null_ls_active_sources, source.name)
  end
  return ("%s[%s]"):format(client.name, table.concat(null_ls_active_sources, ","))
end

local function get_current_lsp()
  local clients = vim.lsp.get_clients()
  local buf_ft = vim.api.nvim_get_option_value("filetype", { buf = 0 })
  local active_clients = {}
  for _, client in ipairs(clients) do
    local source = _get_current_lsp_for_each_client(client, buf_ft)
    if source then table.insert(active_clients, source) end
  end

  -- Only if it's been required before
  local lazyformat = package.loaded["lazyvim.util.format"] ~= nil and require("lazyvim.util.format") or nil
  if lazyformat and lazyformat.enabled() then
    local formatters = lazyformat.resolve()
    for _, formatter in ipairs(formatters) do
      if formatter.active and #formatter.resolved > 0 then
        local s = ("%s[%s]"):format(formatter.name, table.concat(formatter.resolved, ","))
        table.insert(active_clients, s)
      end
    end
  end

  if package.loaded["lint"] then
    local lint = require("lint")
    local formatters = lint._resolve_linter_by_ft(buf_ft)
    if #formatters > 0 then
      local s = string.format("%s[%s]", "nvim-lint", table.concat(formatters, ","))
      table.insert(active_clients, s)
    end
  end

  if #active_clients == 0 then return "No Lsp" end
  return table.concat(active_clients, ",")
end

---@type LazySpec
return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      extensions = { "neo-tree", "lazy", "fugitive", "man", "trouble" },
      options = {
        always_divide_middle = true,
        disabled_filetypes = { statusline = { "alpha", "dashboard", "starter", "nvdash" } },
        globalstatus = true,
        ignore_focus = {},
        refresh = { statusline = 1000, tabline = 1000, winbar = 1000 },
        theme = "auto",
      },
      sections = { -- LEFT SIDE:
        lualine_a = { "mode" },
        lualine_b = { "branch" }, -- Tabnine is added here later
        lualine_c = {
          { "diagnostics", symbols = icons.lualine.diagnostics_symbols },
          {
            "filename",
            path = 1,
            symbols = icons.lualine.filename_symbols,
            separator = "-",
            ---Fix E539 when opening java files. Source: https://github.com/nvim-lualine/lualine.nvim/issues/820#issuecomment-1742621370
            fmt = function(str) ---@param str string
              local fn = vim.fn.expand("%:~:.") --[[@as string]]
              if vim.startswith(fn, "jdt://") then return fn:gsub("?.*$", "") end
              return str
            end,
          },
          "filetype",
          {
            function() return require("nvim-navic").get_location() end,
            cond = function() return package.loaded["nvim-navic"] and require("nvim-navic").is_available() end,
          },
        },
        -- RIGHT SIDE:
        lualine_x = {
          { -- Display keys as they're pressed
            function() return require("noice").api.status.command.get() end,
            cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
            color = getfg("Statement"),
          },
          { -- Display recording status (q)
            function() return require("noice").api.status.mode.get() end,
            cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
            color = getfg("Constant"),
          },
          { -- Debug status
            function() return icons.debug .. require("dap").status() end,
            cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
            color = getfg("Debug"),
          },
          { -- Lazy.nvim update status
            require("lazy.status").updates,
            cond = require("lazy.status").has_updates,
            color = getfg("Special"),
          },
          -- File information
          "encoding",
          "fileformat",
          wordcount,
        },
        lualine_y = {
          get_current_lsp,
          { "progress", separator = " ", padding = { left = 1, right = 0 } },
          { "location", padding = { left = 0, right = 1 } },
        },
        lualine_z = { time },
      },
    },
  },
  {
    "lualine.nvim",
    optional = true,
    opts = function(_, opts)
      opts = vim.tbl_deep_extend("keep", opts or {}, { sections = { lualine_b = {} } })
      table.insert(opts.sections.lualine_b, require("lazy.core.config").spec.plugins["supermaven-nvim"] and {
        function()
          if package.loaded["supermaven-nvim"] then return "🦸 Supermaven" end
          return "🔄 Supermaven"
        end,
      } or "tabnine")
      return opts
    end,
  },
}
