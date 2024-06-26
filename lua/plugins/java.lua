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

---Loads all matches to the quickfix list then opens a telescope picker
---@param result lsp.TypeHierarchyItem[]|nil
---@param ctx {params: {item: lsp.TypeHierarchyItem}}
local function telescope_hierarchy(_, result, ctx)
  if not result then return end
  table.insert(result, 1, ctx.params.item) -- insert the given item at the start of the list
  vim.ui.select(result, {
    ---@return string
    format_item = function(item) ---@param item lsp.TypeHierarchyItem
      local kind = vim.lsp.protocol.SymbolKind[item.kind] or "Unknown"
      return item.name .. " [" .. kind .. "]"
    end,
    prompt = "Select to open:",
  }, function(item) ---@param item lsp.TypeHierarchyItem?
    if not item then return end -- ensure no nil index
    item.range = item.selectionRange -- We prefer to jump at the selectionRange
    vim.lsp.util.jump_to_location(item, "utf-8", true)
  end)
end

local function type_hierarchy(method, handler)
  local params = vim.lsp.util.make_position_params()
  local prepare_method = "textDocument/prepareTypeHierarchy"
  vim.lsp.buf_request(0, prepare_method, params, function(_, result)
    if not result then return end
    vim.lsp.buf_request(0, method, { item = result[1] }, handler)
  end)
end
---@param method string
local function lazy_jdtls_method(method, ...)
  local args = select("#", ...) > 0 and vim.F.pack_len(...) or nil
  return function()
    if not args then return require("jdtls")[method]() end
    return require("jdtls")[method](unpack(args, 1, args.n))
  end
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
    --- Mappings -- <leader>j is java
    keys = {
      { "<leader>ji", lazy_jdtls_method("organize_imports"), desc = "Organize imports" },
      { "<leader>jt", lazy_jdtls_method("test_class"), desc = "Test class" },
      { "<leader>jn", lazy_jdtls_method("test_nearest_method"), desc = "Test nearest method" },
      { "<leader>je", lazy_jdtls_method("extract_variable"), desc = "Extract variable" },
      { "<leader>jM", lazy_jdtls_method("extract_method"), desc = "Extract method" },
      { "<leader>je", lazy_jdtls_method("extract_variable", { visual = true }), desc = "Extract variable", mode = "v" },
      { "<leader>jM", lazy_jdtls_method("extract_method", { visual = true }), desc = "Extract method", mode = "v" },
      {
        "<leader>jh",
        function() return type_hierarchy("typeHierarchy/supertypes", telescope_hierarchy) end,
        desc = "Show Class Hierarchy",
      },
    },
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

      local function attach_jdtls() ---@return nil
        if vim.b._has_run_jdtls_attach then return end
        vim.b._has_run_jdtls_attach = 1
        local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
        ---@type table
        local config = vim.tbl_deep_extend("force", opts, {
          cmd = opts.full_cmd(opts),
          init_options = { bundles = bundles },
        })
        config.root_dir = opts.root_dir(vim.api.nvim_buf_get_name(0)) -- nil needs to be handled
        config.capabilities = vim.tbl_deep_extend(
          "force",
          vim.lsp.protocol.make_client_capabilities(),
          has_cmp and cmp_nvim_lsp.default_capabilities() or {},
          opts.capabilities or {}
        )
        require("jdtls").start_or_attach(extend_or_override(config, opts.override)) -- Existing server will be reused if the root_dir matches.
      end
      -- Attach the jdtls for each java buffer
      create_autocmd("FileType", attach_jdtls, { pattern = "java" })
      -- Avoid race condition by calling attach the first time, since the autocmd won't fire.
      return attach_jdtls()
    end,
  },
}
