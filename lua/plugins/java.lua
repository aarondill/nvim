local consts = require("consts")
local create_autocmd = require("utils.create_autocmd")
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

---@type LazySpec
return {
  -- Configure nvim-lspconfig to install the server automatically via mason, but
  -- defer actually starting it to our configuration of nvim-jtdls below.
  -- make sure mason installs the server & avoid duplicate servers
  { "neovim/nvim-lspconfig", opts = { servers = { jdtls = {} }, setup = { jdtls = function() return true end } } },
  -- Set up nvim-jdtls to attach to java files.
  {
    "mfussenegger/nvim-jdtls",
    dependencies = { "williamboman/mason-lspconfig.nvim" },
    ft = { "java" },
    opts = function()
      local cache = vim.fn.stdpath("cache")
      assert(type(cache) == "string")
      ---@type JDTLSConfig | {}
      return {
        -- How to find the root dir for a given filename. The default comes from
        -- lspconfig which provides a function specifically for java projects.
        root_dir = function() return require("jdtls.setup").find_root(consts.root_markers) end,

        -- How to find the project name for a given root dir.
        project_name = function(root_dir) return root_dir and vim.fs.basename(root_dir) end,

        -- Where are the config and workspace dirs for a project?
        jdtls_config_dir = function(project_name) return vim.fs.joinpath(cache, "jdtls", project_name, "config") end,
        jdtls_workspace_dir = function(project_name) return vim.fs.joinpath(cache, "jdtls", project_name, "workspace") end,

        -- How to run jdtls. This can be overridden to a full java command-line
        -- if the Python wrapper script doesn't suffice.
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
          java = {
            format = {
              enabled = true,
              comments = { enabled = true },
              onType = { enabled = false },
              settings = { url = "~/code/java/java-format.xml" },
            },
          },
        },
      }
    end,
    ---@param opts JDTLSConfig
    config = function(_, opts)
      local mason_registry = require("mason-registry")
      local has_dap = opts.dap and mason_registry.is_installed("java-debug-adapter") and pcall(require, "dap")
      local bundles = {} ---@type string[]
      -- Setup dap after the lsp is fully attached.
      -- https://github.com/mfussenegger/nvim-jdtls#nvim-dap-configuration
      if has_dap then
        create_autocmd("LspAttach", function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if not client or client.name ~= "jdtls" then return end
          require("jdtls").setup_dap(opts.dap) -- custom init for Java debugger
          require("jdtls.dap").setup_dap_main_class_configs(opts.dap_main)
        end)
        -- Find the extra bundles that should be passed on the jdtls command-line if nvim-dap is enabled with java debug/test.
        local java_dbg_path = mason_registry.get_package("java-debug-adapter"):get_install_path()
        local jar_patterns = { java_dbg_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar" }
        -- java-test also depends on java-debug-adapter.
        if opts.test and mason_registry.is_installed("java-test") then
          local java_test_path = mason_registry.get_package("java-test"):get_install_path()
          vim.list_extend(jar_patterns, { java_test_path .. "/extension/server/*.jar" })
        end
        for _, jar_pattern in ipairs(jar_patterns) do
          local files = vim.fn.glob(jar_pattern, false, true) ---@type string[]
          vim.list_extend(bundles, files)
        end
      end

      local function attach_jdtls()
        local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
        local config = vim.tbl_deep_extend("force", opts, {
          cmd = opts.full_cmd(opts),
          root_dir = opts.root_dir(vim.api.nvim_buf_get_name(0)),
          init_options = { bundles = bundles },
        })
        config.capabilities = vim.tbl_deep_extend(
          "force",
          vim.lsp.protocol.make_client_capabilities(),
          has_cmp and cmp_nvim_lsp.default_capabilities() or {},
          opts.capabilities or {}
        )
        return require("jdtls").start_or_attach(extend_or_override(config, opts.override)) -- Existing server will be reused if the root_dir matches.
      end

      -- Attach the jdtls for each java buffer. HOWEVER, this plugin loads
      -- depending on filetype, so this autocmd doesn't run for the first file.
      -- For that, we call directly below.
      create_autocmd("FileType", attach_jdtls, { pattern = "java" })
      -- Avoid race condition by calling attach the first time, since the autocmd won't fire.
      return attach_jdtls()
    end,
  },
}
