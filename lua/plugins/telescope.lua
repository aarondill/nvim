local t = require("utils.telescope")

---@param name string
---@param fn fun(name:string)
local function on_load(name, fn)
  local Config = require("lazy.core.config")
  if Config.plugins[name] and Config.plugins[name]._.loaded then return fn(name) end
  vim.api.nvim_create_autocmd("User", {
    pattern = "LazyLoad",
    callback = function(event)
      if event.data ~= name then return end
      fn(name)
      return true
    end,
  })
end

local function lazy_action(m)
  return function(...) return require("telescope.actions")[m](...) end
end

---@type LazySpec
return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  version = false, -- telescope did only one release, so use HEAD for now
  dependencies = {
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      enabled = vim.fn.executable("make") == 1,
      config = function()
        return on_load("telescope.nvim", function() require("telescope").load_extension("fzf") end)
      end,
    },
  },
  keys = {
    { "<leader>/", t.telescope("live_grep"), desc = "Grep (root dir)" },
    { "<leader>:", "<cmd>Telescope command_history<cr>", desc = "Command History" },
    -- { "<leader><space>", t.telescope("files"), desc = "Find Files (root dir)" },
    -- find
    { "<leader>ff", t.telescope("files"), desc = "Find Files (root dir)" },
    { "<leader>fb", "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>", desc = "Buffers" },
    { "<leader>fg", "<cmd>Telescope git_files<cr>", desc = "Find Files (git-files)" },
    { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent" },
    -- git
    { "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "commits" },
    -- search
    { "<leader>sa", "<cmd>Telescope autocommands<cr>", desc = "Auto Commands" },
    { "<leader>sC", "<cmd>Telescope commands<cr>", desc = "Commands" },
    { "<leader>sD", "<cmd>Telescope diagnostics<cr>", desc = "Workspace diagnostics" },
    { "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Help Pages" },
    { "<leader>sH", "<cmd>Telescope highlights<cr>", desc = "Search Highlight Groups" },
    { "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Key Maps" },
    { "<leader>sM", "<cmd>Telescope man_pages<cr>", desc = "Man Pages" },
    { "<leader>sm", "<cmd>Telescope marks<cr>", desc = "Jump to Mark" },
    { "<leader>so", "<cmd>Telescope vim_options<cr>", desc = "Options" },
    { "<leader>sw", t.telescope("grep_string", { word_match = "-w" }), desc = "Word (root dir)" },
    { "<leader>sw", t.telescope("grep_string"), mode = "v", desc = "Selection (root dir)" },
    { "<leader>uc", "<cmd>Telescope colorscheme enable_preview=true<cr>", desc = "Colorscheme with preview" },
    { "<leader>xx", "<cmd>Telescope diagnostics<cr>", desc = "Workspace Diagnostics" },
    { "<leader>xX", "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Document Diagnostics" },
  },
  opts = {
    pickers = {
      find_files = { hidden = true },
      git_files = { show_untracked = true },
    },
    defaults = {
      prompt_prefix = " ",
      selection_caret = " ",
      -- open files in the first window that is an actual file.
      -- use the current window if no other window is available.
      get_selection_window = function()
        local wins = vim.api.nvim_list_wins()
        table.insert(wins, 1, vim.api.nvim_get_current_win())
        for _, win in ipairs(wins) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].buftype == "" then return win end
        end
        return 0
      end,
      mappings = {
        i = {
          ["<C-Down>"] = lazy_action("cycle_history_next"),
          ["<C-Up>"] = lazy_action("cycle_history_prev"),
          ["<C-f>"] = lazy_action("preview_scrolling_down"),
          ["<C-b>"] = lazy_action("preview_scrolling_up"),
        },
        n = {
          ["q"] = lazy_action("close"),
        },
      },
    },
  },
}
