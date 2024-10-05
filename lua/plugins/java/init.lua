local consts = require("consts")
local create_autocmd = require("utils.create_autocmd")
local h = require("plugins.java.hierarchy")
---@class JDTLSConfig :lspconfig.options.jdtls
---@field dap? JdtSetupDapOpts
---@field dap_main? JdtSetupMainConfigOpts
---@field full_cmd fun(opts: JDTLSConfig): string[]
---@field test boolean
---@field override? lspconfig.options.jdtls|fun(c: JDTLSConfig):lspconfig.options.jdtls?
---How to find the project name for a given root dir.
---@field project_name fun(root_dir?: string): string?
---Where are the config and workspace dirs for a project?
---@field jdtls_config_dir fun(project_name: string): string
---Where are the config and workspace dirs for a project?
---@field jdtls_workspace_dir fun(project_name: string): string

---Utility function to extend or override a config table, similar to the way that Plugin.opts works.
---@param config table
---@param custom? function|table
local function extend_or_override(config, custom, ...)
  if not custom then return config end
  if type(custom) == "function" then return custom(config, ...) or config end
  return vim.tbl_deep_extend("force", config, custom)
end

local cache = vim.fn.stdpath("cache")
assert(type(cache) == "string")

---@type LazySpec
return {
  {
    "mfussenegger/nvim-jdtls",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      -- Defer nvim-lspconfig starting server to nvim-jtdls.
      { "neovim/nvim-lspconfig", optional = true, opts = { setup = { jdtls = function() return true end } } },
    },
    ft = { "java" },
    keys = { --- Mappings -- <leader>j is java
      {
        "<leader>jh",
        function() return h.type_hierarchy("typeHierarchy/supertypes", h.telescope_hierarchy) end,
        desc = "Show Class Hierarchy (supertypes)",
      },
      {
        "<leader>jH",
        function() return h.type_hierarchy("typeHierarchy/subtypes", h.telescope_hierarchy) end,
        desc = "Show Class Hierarchy (subtypes)",
      },
    },
    opts = function()
      ---@type JDTLSConfig | {}
      return {
        -- How to find the root dir for a given filename.
        root_dir = function() return require("jdtls.setup").find_root(consts.root_markers) end,

        -- How to find the project name for a given root dir.
        project_name = function(root_dir) return root_dir and vim.fs.basename(root_dir) end,

        -- Where are the config and workspace dirs for a project?
        jdtls_config_dir = function(project_name) return vim.fs.joinpath(cache, "jdtls", project_name, "config") end,
        jdtls_workspace_dir = function(project_name) return vim.fs.joinpath(cache, "jdtls", project_name, "workspace") end,

        -- How to run jdtls. This can be overridden to a full java command-line.
        cmd = { vim.fn.exepath("jdtls") },
        full_cmd = function(opts) ---@param opts JDTLSConfig
          local fname = vim.api.nvim_buf_get_name(0)
          local root_dir = opts.root_dir(fname)
          local project_name = opts.project_name(root_dir)
          local cmd = vim.deepcopy(opts.cmd)
          if not project_name then return cmd end
          return vim.list_extend(cmd, {
            "-configuration",
            opts.jdtls_config_dir(project_name),
            "-data",
            opts.jdtls_workspace_dir(project_name),
          })
        end,
        ---didChangeWatchedFiles is broken! See mfussenegger/nvim-jdtls#645
        capabilities = { workspace = { didChangeWatchedFiles = { dynamicRegistration = false } } },

        -- These depend on nvim-dap, but can additionally be disabled by setting false here.
        dap = { hotcodereplace = "auto", config_overrides = {} },
        dap_main = {},
        settings = {
          redhat = { telemetry = { enabled = false } },
          ---@diagnostic disable-next-line: missing-fields
          java = {
            format = {
              enabled = true,
              comments = { enabled = true },
              onType = { enabled = false },
              settings = { url = "~/code/java/java-format.xml" }, ---@diagnostic disable-line: missing-fields
            },
          },
        },
      }
    end,
    ---@param opts JDTLSConfig
    config = function(_, opts)
      local function attach_jdtls() ---@return nil
        if vim.b._has_run_jdtls_attach then return end
        vim.b._has_run_jdtls_attach = 1
        local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
        ---@type table
        local config = vim.tbl_deep_extend("force", opts, { cmd = opts.full_cmd(opts) })
        config.root_dir = opts.root_dir(vim.api.nvim_buf_get_name(0)) -- nil needs to be handled
        config.capabilities = vim.tbl_deep_extend(
          "force",
          vim.lsp.protocol.make_client_capabilities(),
          has_cmp and cmp_nvim_lsp.default_capabilities() or {},
          opts.capabilities or {}
        )
        require("jdtls").start_or_attach(extend_or_override(config, opts.override)) -- Existing server will be reused if the root_dir matches.
      end
      create_autocmd("FileType", attach_jdtls, { pattern = "java" }) -- Attach the jdtls for each java buffer
      -- Avoid race condition by calling attach the first time, since the autocmd won't fire.
      return attach_jdtls()
    end,
  },
}
