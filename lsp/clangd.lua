local root = require("utils.root")
local setup_files = { "compile_commands.json", "compile_flags.txt", ".clangd" }
local warning_message =
  "clangd: No compile_commands.json or compile_flags.txt found! You may need to run the build system."

require("utils.create_autocmd")("LspAttach", function(ev)
  local client = vim.lsp.get_client_by_id(ev.data.client_id)
  if not client or client.name ~= "clangd" then return end
  local rootDir = root.get({ buf = ev.buf })
  local found = vim.fs.find(setup_files, { upward = true, limit = 1, type = "file", path = rootDir })
  if vim.tbl_count(found) > 0 then return end
  require("utils.notifications").warn(warning_message)
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
