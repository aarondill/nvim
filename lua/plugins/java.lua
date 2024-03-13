local consts = require("consts")
local create_autocmd = require("utils.create_autocmd")
---@param method string
local function lazy_method(method, ...)
  local args = vim.F.pack_len(...)
  return function() return require("jdtls")[method](vim.F.unpack_len(args)) end
end

local keys = {
  { "<leader>cJi", lazy_method("organize_imports"), desc = "Organize imports" },
  { "<leader>cJt", lazy_method("test_class"), desc = "Test class" },
  { "<leader>cJn", lazy_method("test_nearest_method"), desc = "Test nearest method" },
  { "<leader>cJe", lazy_method("extract_variable"), desc = "Extract variable" },
  { "<leader>cJM", lazy_method("extract_method"), desc = "Extract method" },
  {
    "<leader>cJe",
    lazy_method("extract_variable", { visual = true }),
    desc = "Extract variable",
    mode = "v",
  },
  { "<leader>cJM", lazy_method("extract_method", { visual = true }), desc = "Extract method", mode = "v" },
}

local function setup_jdtls(opts)
  local jdtls = require("jdtls")
  local root_dir = require("jdtls.setup").find_root(consts.root_markers)
  -- `~/dev/xy/project-1` -> `project-1`
  local project_name = vim.fn.fnamemodify(root_dir or vim.fn.getcwd(), ":p:h:t")
  local cachedir = vim.fn.stdpath("cache")
  assert(type(cachedir) == "string")
  local workspace_dir = vim.fs.joinpath(cachedir, "jdtls", "workspace", project_name)

  local config = vim.tbl_extend("force", vim.deepcopy(opts) or {}, { root_dir = root_dir })
  vim.list_extend(assert(config.cmd), { "-data", workspace_dir })
  jdtls.start_or_attach(config)
  if pcall(require, "dap") then jdtls.setup_dap({ hotcodereplace = "auto", config_overrides = {} }) end
end

---@type LazySpec
return {
  {
    "neovim/nvim-lspconfig",
    dependencies = { "mfussenegger/nvim-jdtls" },
    ---@type PluginLspOpts
    opts = {
      servers = {
        jdtls = {
          cmd = { "jdtls" },
          settings = {
            redhat = { telemetry = { enabled = false } },
            java = {
              home = nil, ---@type nil This is FINE!
              format = {
                enabled = true,
                comments = { enabled = true },
                onType = { enabled = false },
                settings = {
                  url = "~/code/java/java-format.xml",
                  profile = nil, ---@type nil - the config is defined above
                },
              },
            },
          },
        },
      },
      setup = {
        jdtls = function(_, opts)
          create_autocmd("FileType", function() return setup_jdtls(opts) end, { pattern = "java" })
          return true
        end,
      },
    },
  },
}
