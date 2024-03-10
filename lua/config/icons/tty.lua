---@class custom_icons
--- Icons will be automatically pulled from tty if necessary
--- Icons will otherwise be gotten from gui, falling back to the tty icon if not available
--- Note: this only works on the top level. if a table is returned, no such promises are made.
return {
  clock = "",
  debug = "debug ",
  lualine = {
    options = { -- *This* is safe to pass to lualine.opts.options
      section_separators = { left = ">", right = "<" },
      component_separators = { left = "|", right = "|" },
    },
    -- Note: This can't be passed to lualine.opts because of *_symbols
    filename_symbols = { modified = " M ", readonly = "RO ", unnamed = "" },
    diagnostics_symbols = { error = "X ", warn = "! ", hint = "> ", info = "I " },
  },
  ["package-info"] = {
    icons = {
      style = { up_to_date = "| ", outdated = "X " },
    },
  },
  ["neo-tree"] = { -- {{{ 1
    default_component_configs = {
      modified = { symbol = "[+] " },
      indent = {
        indent_marker = "|",
        last_indent_marker = ">",
        expander_collapsed = "▶",
        expander_expanded = "▼",
      },
      icon = {
        folder_closed = "-",
        folder_open = "+",
        folder_empty = "_",
        folder_empty_open = "_>",
        default = "*",
      },
      git_status = {
        symbols = { -- Change type
          added = "", -- or "✚", but this is redundant info if you use git_status_colors on the name
          modified = "", -- or "", but this is redundant info if you use git_status_colors on the name
          deleted = "x", -- this can only be used in the git_status source
          renamed = "->", -- this can only be used in the git_status source
          untracked = "?",
          ignored = "/",
          unstaged = "_",
          staged = "+",
          conflict = "!",
        },
      },
    },
  }, -- }}}
  telescope = { defaults = { prompt_prefix = "> ", selection_caret = "> " } },
  flash_prompt = "Flash: ",
  gitsigns = {
    signs = {
      add = { text = "+" },
      change = { text = "|" },
      delete = { text = "-" },
      topdelete = { text = "-" },
      changedelete = { text = ":" },
      untracked = { text = "?" },
    },
  },
  lazyvim = {
    icons = { -- {{{ 1
      dap = {
        Stopped = { "-> ", "DiagnosticWarn", "DapStoppedLine" },
        Breakpoint = "X ",
        BreakpointCondition = "? ",
        BreakpointRejected = { "! ", "DiagnosticError" },
        LogPoint = ".>",
      },
      diagnostics = { Error = "X ", Warn = "! ", Hint = "> ", Info = "I " },
      git = { added = "+ ", modified = "M ", removed = "- " },
      kinds = {
        Array = "[] ",
        Boolean = "",
        Class = "",
        Color = "",
        Constant = "",
        Constructor = "",
        Copilot = "",
        Enum = "",
        EnumMember = "",
        Event = "",
        Field = "",
        File = "File ",
        Folder = "Folder ",
        Function = "Func ",
        Interface = "",
        Key = "ABC ",
        Keyword = "",
        Method = "Method ",
        Module = "Mod ",
        Namespace = "{} ",
        Null = "NULL ",
        Number = "# ",
        Object = "{} ",
        Operator = "+- ",
        Package = "",
        Property = "",
        Reference = "",
        Snippet = "",
        String = "",
        Struct = "",
        Text = "",
        TypeParameter = "<T> ",
        Unit = "",
        Value = "ABC ",
        Variable = "<V> ",
      },
    },
  }, -- }}}
  noice = { -- {{{ 1
    cmdline = {
      format = {
        cmdline = { icon = "> " },
        search_down = { icon = "/ " },
        search_up = { icon = "? " },
        filter = { icon = "$" },
        lua = { icon = "L " },
        help = { icon = "? " },
        calculator = { icon = "* " },
        IncRename = { icon = "RENAME " },
      },
    },
    format = { level = { icons = { error = "X ", info = "I ", warn = "! " } } },
    popupmenu = {
      kind_icons = {
        Class = "",
        Color = "",
        Constant = "",
        Constructor = "",
        Enum = " ",
        EnumMember = "",
        Field = "",
        File = "",
        Folder = "",
        Function = "",
        Interface = "",
        Keyword = "",
        Method = "",
        Module = "",
        Property = "",
        Snippet = "",
        Struct = "",
        Text = "",
        Unit = "",
        Value = "",
        Variable = "",
      },
    },
  }, -- }}}
  lazy_nvim = {
    ui = {
      icons = {
        cmd = "",
        config = "",
        event = "",
        ft = "",
        init = "",
        import = "",
        keys = "",
        lazy = "lazy",
        loaded = "->",
        not_loaded = "X",
        plugin = "",
        runtime = "",
        source = "",
        start = "",
        task = "",
        list = {
          "",
          "",
          "",
          "",
        },
      },
    },
  },
}
