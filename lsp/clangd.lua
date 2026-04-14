local notifications = require("utils.notifications")
local root = require("utils.root")
local setup_files = { "compile_commands.json", "compile_flags.txt", ".clangd" }
local warning_message =
  "clangd: No compile_commands.json or compile_flags.txt found! You may need to run the build system."

---@param rootDir string
---@param allow_bear boolean? [default=true]
local function find_compile_commands(rootDir, allow_bear)
  local found = vim.fs.find(setup_files, { upward = true, limit = 1, type = "file", path = rootDir })
  if vim.tbl_count(found) > 0 then return end

  allow_bear = allow_bear == nil and true or allow_bear
  if not vim.fn.executable("bear") then allow_bear = false end

  if not allow_bear then return notifications.warn(warning_message) end -- no bear and no compile_commands.json

  local make = vim.fs.find({ "Makefile", "makefile" }, { upward = true, limit = 1, type = "file", path = rootDir })
  -- there's a makefile, but no compile_commands.json or compile_flags.txt
  if vim.tbl_count(make) > 0 then
    notifications.info("clangd: running bear make to generate compile_commands.json")
    return vim.system({ "bear", "--", "make", "-B" }, { cwd = rootDir, timeout = 1000 }, function(code)
      if code ~= 0 then notifications.warn("clangd: bear make failed") end
      return find_compile_commands(rootDir, false) -- no infinite loops
    end)
  end
end

require("utils.create_autocmd")("LspAttach", function(ev)
  local client = vim.lsp.get_client_by_id(ev.data.client_id)
  if not client or client.name ~= "clangd" then return end
  local rootDir = root.get({ buf = ev.buf })
  find_compile_commands(rootDir)
end, { group = vim.api.nvim_create_augroup("clangd", { clear = true }) })

return { ---@type vim.lsp.Config
  settings = { clangd = {} },
  cmd = {
    "clangd",
    "-j=4",
    "--background-index",
    "--clang-tidy",
    "--inlay-hints",
    "--fallback-style=llvm",
    "--all-scopes-completion",
    "--completion-style=detailed",
    "--header-insertion=iwyu",
    "--header-insertion-decorators",
    "--pch-storage=memory",
  },
}
