local consts = require("consts")
local create_autocmd = require("utils.create_autocmd")
local flatten = require("utils.flatten")
local h = require("plugins.java.hierarchy")

local cache = vim.fn.stdpath("cache")
assert(type(cache) == "string")
-- Where are the config and workspace dirs for a project?
local function jdtls_config_dir(project_name) return vim.fs.joinpath(cache, "jdtls", project_name, "config") end
local function jdtls_workspace_dir(project_name) return vim.fs.joinpath(cache, "jdtls", project_name, "workspace") end

---@type vim.lsp.ClientConfig
local o = {
  -- How to find the root dir for a given filename.
  root_markers = consts.root_markers,
  cmd = { "jdtls" },
  ---didChangeWatchedFiles is broken! See mfussenegger/nvim-jdtls#645
  capabilities = { workspace = { didChangeWatchedFiles = { dynamicRegistration = false } } },
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
vim.lsp.config("jdtls", o)

---@type LazySpec
return {
  {
    "mfussenegger/nvim-jdtls",
    dependencies = {
      { "williamboman/mason-lspconfig.nvim", optional = true, opts = { automatic_enable = { exclude = { "jdtls" } } } }, -- Defer starting server to nvim-jtdls.
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
    cmd = flatten(
      { "JdtBytecode", "JdtCompile", "JdtJol", "JdtJshell", "JdtRestart" },
      { "JdtSetRuntime", "JdtShowLogs", "JdtShowMavenActiveProfiles" },
      { "JdtUpdateConfig", "JdtUpdateMavenActiveProfiles", "JdtWipeDataAndRestart" }
    ),
    config = function()
      local function attach_jdtls() ---@return nil
        if vim.b._has_run_jdtls_attach then return end
        vim.b._has_run_jdtls_attach = 1
        local config = vim.lsp.config.jdtls -- handles capabilities

        local root_dir = config.root_dir
        if type(root_dir) ~= "string" then root_dir = vim.fs.root(0, config.root_markers) end
        config = vim.tbl_deep_extend("force", config, { root_dir = root_dir })
        -- How to find the project name for a given root dir.
        local project_name = vim.fs.basename(root_dir)
        if project_name then
          local workspace, cmd = jdtls_workspace_dir(project_name), config.cmd
          assert(type(cmd) == "table", "Expected cmd to be a table (jdtls)")
          ---@type table
          config = vim.tbl_deep_extend("force", config, {
            init_options = { workspace = workspace },
            cmd = vim.list_extend(vim.deepcopy(cmd), {
              "-configuration",
              jdtls_config_dir(project_name),
              "-data",
              workspace,
            }),
          })
        end
        require("jdtls").start_or_attach(config) -- Existing server will be reused if the root_dir matches.
      end
      create_autocmd("FileType", attach_jdtls, { pattern = "java" }) -- Attach the jdtls for each java buffer
      -- Avoid race condition by calling attach the first time, since the autocmd won't fire.
      return attach_jdtls()
    end,
  },
}
