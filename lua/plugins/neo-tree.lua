local create_autocmd = require("utils.create_autocmd")
local root = require("utils.root")

---@param from string
---@param to string
local function on_rename(from, to)
  local clients = vim.lsp.get_clients()
  for _, client in ipairs(clients) do
    if client.supports_method("workspace/willRenameFiles") then
      local resp = client.request_sync("workspace/willRenameFiles", {
        files = {
          {
            oldUri = vim.uri_from_fname(from),
            newUri = vim.uri_from_fname(to),
          },
        },
      }, 1000, 0)
      if resp and resp.result ~= nil then vim.lsp.util.apply_workspace_edit(resp.result, client.offset_encoding) end
    end
  end
end

---@type LazySpec
return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  cmd = "Neotree",
  keys = {
    {
      "<leader>ee",
      function() require("neo-tree.command").execute({ toggle = true, dir = root.get() }) end,
      desc = "Explorer NeoTree (root dir)",
    },
    {
      "<leader>E",
      function() require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() }) end,
      desc = "Explorer NeoTree (cwd)",
    },
    {
      "<leader>ge",
      function() require("neo-tree.command").execute({ toggle = true, source = "git_status" }) end,
      desc = "Git explorer",
    },
  },
  deactivate = function() vim.cmd([[Neotree close]]) end,
  init = function()
    --- Load neo-tree if we try to edit a directory
    create_autocmd({ "BufEnter", "BufWinEnter" }, function(ev)
      if package.loaded["neo-tree"] then return true end -- don't do anything if it's already loaded
      local stat = vim.uv.fs_stat(ev.file)
      if not stat or stat.type ~= "directory" then return end
      require("neo-tree") -- load neo-tree
      return true -- we don't need this anymore
    end)
    if vim.fn.argc(-1) == 1 then -- if only one argument
      local dir = assert(vim.fn.argv(0))
      assert(type(dir) == "string")
      local stat = vim.loop.fs_stat(dir)
      if not stat or stat.type ~= "directory" then return end
      require("neo-tree") -- load neotree to take over netrw
    end
  end,
  opts = {
    sources = { "filesystem", "buffers", "git_status", "document_symbols" },
    open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
    filesystem = {
      bind_to_cwd = false,
      follow_current_file = { enabled = true },
      use_libuv_file_watcher = true,
      hijack_netrw_behavior = "open_current",
      filtered_items = {
        hide_dotfiles = false,
        hide_gitignored = false,
        hide_hidden = false,
      },
    },
    window = {
      mappings = {
        ["<space>"] = "none",
        ["o"] = "open", -- Open on 'o'
        ["/"] = "noop", -- Don't fuzzy find on '/', use neovim's search instead
        ["Y"] = {
          function(state)
            local node = state.tree:get_node()
            local path = node:get_id()
            vim.fn.setreg("+", path, "c")
          end,
          desc = "copy path to clipboard",
        },
      },
    },
    default_component_configs = {
      indent = {
        with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
        expander_collapsed = "",
        expander_expanded = "",
        expander_highlight = "NeoTreeExpander",
      },
    },
  },
  config = function(_, opts)
    local function on_move(data) on_rename(data.source, data.destination) end
    opts = opts or {}
    opts.event_handlers = opts.event_handlers or {}
    vim.list_extend(opts.event_handlers, {
      { event = require("neo-tree.events").FILE_MOVED, handler = on_move },
      { event = require("neo-tree.events").FILE_RENAMED, handler = on_move },
    })
    require("neo-tree").setup(opts)
    vim.api.nvim_create_autocmd("TermClose", {
      pattern = "*lazygit",
      callback = function()
        if not package.loaded["neo-tree.sources.git_status"] then return end
        require("neo-tree.sources.git_status").refresh()
      end,
    })
  end,
}
