---@class custom_icons
--- Icons will fall back to the tty icon if not available
--- Note: this only works on the top level. if a table is returned, no such promises are made.
local M = {
  clock = " ",
  debug = " ",
  ["neo-tree"] = { -- {{{ 1
    default_component_configs = {
      git_status = {
        symbols = {
          added = "✚",
          conflict = "",
          deleted = "✖",
          ignored = "",
          modified = "",
          renamed = "󰁕",
          staged = "",
          unstaged = "󰄱",
          untracked = "",
        },
      },
      icon = {
        default = "*",
        folder_closed = "",
        folder_empty = "󰜌",
        folder_empty_open = "󰜌",
        folder_open = "",
      },
      indent = {
        expander_collapsed = "",
        expander_expanded = "",
        indent_marker = "│",
        last_indent_marker = "└",
      },
      modified = { symbol = "[+] " },
    },
  }, -- }}}
  ["package-info"] = {
    icons = {
      style = { up_to_date = "|  ", outdated = "|  " },
    },
  },
  lualine = {
    options = { -- *This* is safe to pass to lualine.opts.options
      section_separators = { left = "", right = "" },
      component_separators = { left = "|", right = "|" },
    },
    -- Note: This can't be passed to lualine.opts because of *_symbols
    filename_symbols = { modified = "  ", readonly = "󰌾 ", unnamed = "" },
    diagnostics_symbols = { error = " ", hint = " ", info = " ", warn = " " },
  },
  lazyvim = {
    icons = { -- {{{ 1
      dap = {
        Breakpoint = " ",
        BreakpointCondition = " ",
        BreakpointRejected = { " ", "DiagnosticError" },
        LogPoint = ".>",
        Stopped = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
      },
      diagnostics = { Error = " ", Hint = " ", Info = " ", Warn = " " },
      git = { added = " ", modified = " ", removed = " " },
      kinds = {
        Array = " ",
        Boolean = " ",
        Class = " ",
        Color = " ",
        Constant = " ",
        Constructor = " ",
        Copilot = " ",
        Enum = " ",
        EnumMember = " ",
        Event = " ",
        Field = " ",
        File = " ",
        Folder = " ",
        Function = " ",
        Interface = " ",
        Key = " ",
        Keyword = " ",
        Method = " ",
        Module = " ",
        Namespace = " ",
        Null = " ",
        Number = " ",
        Object = " ",
        Operator = " ",
        Package = " ",
        Property = " ",
        Reference = " ",
        Snippet = " ",
        String = " ",
        Struct = " ",
        Text = " ",
        TypeParameter = " ",
        Unit = " ",
        Value = " ",
        Variable = " ",
      },
    },
  }, -- }}}
  telescope = { defaults = { prompt_prefix = " ", selection_caret = " " } },
  gitsigns = {
    signs = {
      add = { text = "▎" },
      change = { text = "▎" },
      changedelete = { text = "▎" },
      delete = { text = "" },
      topdelete = { text = "" },
      untracked = { text = "▎" },
    },
  },
  flash_prompt = "⚡",
  noice = { -- {{{ 1
    cmdline = {
      format = {
        IncRename = { icon = " " },
        calculator = { icon = "" },
        cmdline = { icon = "" },
        filter = { icon = "$" },
        help = { icon = "" },
        lua = { icon = "" },
        search_down = { icon = " " },
        search_up = { icon = " " },
      },
    },
    format = { level = { icons = { error = " ", info = " ", warn = " " } } },
    popupmenu = {
      kind_icons = {
        Class = " ",
        Color = " ",
        Constant = " ",
        Constructor = " ",
        Enum = "了 ",
        EnumMember = " ",
        Field = " ",
        File = " ",
        Folder = " ",
        Function = " ",
        Interface = " ",
        Keyword = " ",
        Method = "ƒ ",
        Module = " ",
        Property = " ",
        Snippet = " ",
        Struct = " ",
        Text = " ",
        Unit = " ",
        Value = " ",
        Variable = " ",
      },
    },
  }, -- }}}
  lazy_nvim = {
    ui = {
      icons = {
        cmd = " ",
        config = "",
        event = "",
        ft = " ",
        init = " ",
        import = " ",
        keys = " ",
        lazy = "󰒲 ",
        loaded = "●",
        not_loaded = "○",
        plugin = " ",
        runtime = " ",
        source = " ",
        start = "",
        task = "✔ ",
        list = {
          "●",
          "➜",
          "★",
          "‒",
        },
      },
    },
  },
}

--- If index not found, try the tty table
return setmetatable(M, {
  __index = function(_, key) return require("config.icons.tty")[key] end,
})
