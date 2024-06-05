local create_autocmd = require("utils.create_autocmd")
local remap = require("plugins.lsp.keymaps").apply
---@type LazySpec
return {
  { import = "plugins.lsp.servers" }, -- Import the configuration from lsp servers
  {
    "neovim/nvim-lspconfig",
    event = "LazyFile",
    dependencies = { -- load these before lspconfig
      "folke/neoconf.nvim",
      "mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    ---@class PluginLspOpts
    opts = {
      capabilities = {}, -- add any global capabilities here
      servers = {}, ---@type lspconfig.options | {}
      setup = {}, ---@type table<string, fun(server:string, opts:_.lspconfig.options): boolean?>
    },
    config = function(_, opts) ---@param opts PluginLspOpts
      require("utils.format").register(require("plugins.lsp.formatter").formatter())
      create_autocmd("LspAttach", function(args) return remap(args.data.client_id, args.buf) end)
      local register_capability = vim.lsp.handlers["client/registerCapability"]
      vim.lsp.handlers["client/registerCapability"] = function(err, res, ctx) ---@diagnostic disable-line: duplicate-set-field
        local ret = register_capability(err, res, ctx)
        remap(ctx.client_id, ctx.bufnr)
        return ret
      end

      -- diagnostics
      local icons = require("config.icons").lazyvim.icons
      local signs = {
        DiagnosticSignError = icons.diagnostics.Error,
        DiagnosticSignWarn = icons.diagnostics.Warn,
        DiagnosticSignHint = icons.diagnostics.Hint,
        DiagnosticSignInfo = icons.diagnostics.Info,
      }
      for name, text in pairs(signs) do
        vim.fn.sign_define(name, { texthl = name, text = text, numhl = "" })
      end

      local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        has_cmp and cmp_nvim_lsp.default_capabilities() or {},
        opts.capabilities or {}
      )

      local function setup(server)
        local server_opts = vim.tbl_deep_extend("force", { capabilities = capabilities }, opts.servers[server] or {})
        local f = opts.setup[server] or opts.setup["*"]
        if f and f(server, server_opts) then return end
        return require("lspconfig")[server].setup(server_opts)
      end

      -- get all the servers that are available through mason-lspconfig
      local have_mlsp, mlsp = pcall(require, "mason-lspconfig")
      local mlsp_servers = have_mlsp and vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)
        or {}

      local ensure_installed = {} ---@type string[]
      for server, server_opts in pairs(opts.servers) do
        if server_opts == true then server_opts = {} end
        if server_opts then
          local use_mason = server_opts.mason == nil or server_opts and vim.tbl_contains(mlsp_servers, server)
          if server_opts.enabled ~= false then
            if use_mason then
              ensure_installed[#ensure_installed + 1] = server
            else
              setup(server)
            end
          end
        end
      end

      if have_mlsp then mlsp.setup({ ensure_installed = ensure_installed, handlers = { setup } }) end
    end,
  },
  { "williamboman/mason-lspconfig.nvim", dependencies = { "mason.nvim" } },
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
    dependencies = { "nvim-lspconfig" },
  },
  --- Lazy Dev
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "luvit-meta/library", words = { "vim%.uv" } },
        "lazy.nvim",
        { path = "wezterm-types", mods = { "wezterm" } },
      },
    },
  },
  { "justinsgithub/wezterm-types", lazy = true },
  { "Bilal2453/luvit-meta", lazy = true }, -- `vim.uv` typings
  { -- completion source for require statements and module annotations
    "hrsh7th/nvim-cmp",
    optional = true,
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      table.insert(opts.sources, {
        name = "lazydev",
        group_index = 0, -- set group index to 0 to skip loading LuaLS completions
      })
    end,
  },
  { "folke/neodev.nvim", optional = true, enabled = false }, -- make sure to disable neodev.nvim
}
