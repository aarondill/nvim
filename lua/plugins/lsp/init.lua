local create_autocmd = require("utils.create_autocmd")
local keymaps = require("plugins.lsp.keymaps")

---@type table<integer, boolean>
local lsp_initialized_buffers = {}
---@param args EventInfo
local function LspAttach(args)
  if lsp_initialized_buffers[args.buf] then return end
  lsp_initialized_buffers[args.buf] = true
  return keymaps.apply(args.data.client_id, args.buf)
end

---@type LazySpec
return {
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "mason.nvim" },
    opts_extend = { "ensure_installed", "automatic_enable.exclude" },
    opts = { ensure_installed = {}, automatic_enable = { exclude = {} } },
  },
  --- Import the configuration from lsp servers
  --- NOTE: This *must* be after mason-lspconfig.nvim, since it relies on opts_extend
  { import = "plugins.lsp.servers" },
  {
    "neovim/nvim-lspconfig",
    event = "LazyFile",
    dependencies = { -- load these before lspconfig
      "folke/neoconf.nvim",
      "mason.nvim",
      "mason-lspconfig.nvim",
    },
    config = function()
      require("utils.format").register(require("plugins.lsp.formatter").formatter())
      require("utils.format").register(require("utils.organize_imports").formatter())
      create_autocmd("LspAttach", LspAttach)

      --- Diagnostics
      local icons = require("config.icons")
      local signs = {
        DiagnosticSignError = icons.diagnostics.Error,
        DiagnosticSignWarn = icons.diagnostics.Warn,
        DiagnosticSignHint = icons.diagnostics.Hint,
        DiagnosticSignInfo = icons.diagnostics.Info,
      }
      for name, text in pairs(signs) do
        vim.fn.sign_define(name, { texthl = name, text = text, numhl = "" })
      end

      --- Capabilities
      local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      local capabilities = vim.tbl_deep_extend(
        "force",
        vim.lsp.protocol.make_client_capabilities(),
        has_cmp and cmp_nvim_lsp.default_capabilities() or {}
      )
      vim.lsp.config("*", { capabilities = capabilities })
    end,
  },
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    opts = { ensure_installed = { "stylua", "shfmt" } },
    ---@param opts MasonSettings | {ensure_installed: string[]}
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      local ft = function()
        return pcall(vim.api.nvim_exec_autocmds, "FileType", { buffer = vim.api.nvim_get_current_buf() })
      end
      mr:on("package:install:success", vim.schedule_wrap(ft)) -- trigger FileType event to possibly load this newly installed LSP server
      local function ensure_installed()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then p:install() end
        end
      end
      if not mr.refresh then return ensure_installed() end
      return mr.refresh(ensure_installed)
    end,
  },
  {
    "folke/neoconf.nvim",
    cmd = "Neoconf",
    opts = {},
  },
  --- Lazy Dev
  {
    "folke/lazydev.nvim",
    ft = "lua",
    cmd = "LazyDev",
    ---@module 'lazydev'
    ---@type lazydev.Config|{}
    opts = {
      enabled = function(root_dir) -- Default to off unless `lazydev_enabled` is set to true or we're under ~/.config/nvim
        if vim.g.lazydev_enabled or root_dir == vim.fn.expand("~/.config/nvim") then return true end
        --- Note: lua/ is possible a false-positive, but it's unlikely to be used in a non-nvim project
        for _, path in ipairs({ "plugin/", "autoload/", "after/", ".neoconf.json", "lua/" }) do
          local full_path = vim.fs.joinpath(root_dir, path)
          local exists = vim.uv.fs_stat(full_path) ~= nil
          if exists then return true end
        end
      end,
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv", "vim%.loop" } },
        { "lazy.nvim", words = { "Lazy", "lazy" } },
        { path = "wezterm-types", mods = { "wezterm" } },
      },
    },
  },
  { -- optional completion source for require statements and module annotations
    "hrsh7th/nvim-cmp",
    optional = true,
    opts = function(_, opts)
      _ = _ ---@module 'cmp'
      opts.sources = opts.sources or {} ---@type cmp.SourceConfig[]
      opts.sources[#opts.sources + 1] = {
        name = "lazydev",
        group_index = 0, -- set group index to 0 to skip loading LuaLS completions
      }
    end,
  },
  { "justinsgithub/wezterm-types", lazy = true },
}
