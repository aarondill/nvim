local map = require("utils.map")
local M = {}

local function has_plugin(p) return require("lazy.core.config").spec.plugins[p] ~= nil end

local function find(word, ...)
  for _, str in ipairs({ ... }) do
    local match_start, match_end = string.find(word, str)
    if match_start then return str, match_start, match_end end
  end
end
local function open_help(tag) return pcall(vim.cmd.help, tag) end
---open vim help docs if vim.api or vim.fn, otherwise lsp hover
local function hover()
  local ft = vim.bo.filetype
  if ft ~= "lua" and ft ~= "vim" then return vim.lsp.buf.hover() end
  local word
  do --- get the word under cursor
    local original_iskeyword = vim.bo.iskeyword
    vim.bo.iskeyword = vim.bo.iskeyword .. ",."
    word = vim.fn.expand("<cword>")
    vim.bo.iskeyword = original_iskeyword
  end

  local match, _, end_idx = find(word, "^api.", "^vim.api.")
  if match and end_idx then
    local r = open_help(word:sub(end_idx + 1))
    if r then return end
  end

  match, _, end_idx = find(word, "^fn.", "^vim.fn.")
  if match and end_idx then
    local r = open_help(word:sub(end_idx + 1) .. "()")
    if r then return end
  end

  match, _, end_idx = find(word, "^vim.([a-zA-Z_.]+)")
  if match and end_idx then
    local r = open_help(word:sub(1, end_idx))
    if r then return end
  end
  return vim.lsp.buf.hover()
end

---@param client integer|vim.lsp.Client
---@param buffer? integer
function M.apply(client, buffer)
  if type(client) == "number" then client = assert(vim.lsp.get_client_by_id(client)) end
  buffer = buffer or vim.api.nvim_get_current_buf()
  local function telescope_builtin(key)
    return function() return require("telescope.builtin")[key]({ reuse_win = true }) end
  end
  local source_action = function()
    return vim.lsp.buf.code_action({ context = { only = { "source" }, diagnostics = {} } })
  end

  local rename_rhs, rename_is_expr = vim.lsp.buf.rename, false
  if has_plugin("inc-rename.nvim") then -- we have inc-rename
    rename_rhs = function() return (":%s %s"):format(require("inc_rename").config.cmd_name, vim.fn.expand("<cword>")) end
    rename_is_expr = true
  end

  ---@type ({mode?:string[]|string,[1]: string|string[], [2]: string|(fun():any?), desc:string, cond: any})[]
  local keys = {
    { "gd", telescope_builtin("lsp_definitions"), desc = "Goto Definition" },
    { "gD", vim.lsp.buf.declaration, desc = "Goto declaration" },
    { "gr", "<cmd>Telescope lsp_references<cr>", desc = "References" },
    { "gI", telescope_builtin("lsp_implementations"), desc = "Goto Implementation" },
    { "gy", telescope_builtin("lsp_type_definitions"), desc = "Goto T[y]pe Definition" },
    { "K", hover, desc = "Hover" },
    { "gK", vim.lsp.buf.signature_help, desc = "Signature Help" },
    { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "v" } },
    {
      "<leader>co",
      function() return require("utils.organize_imports").organize_imports(0, true) end,
      desc = "Organize Imports",
      mode = { "n" },
    },
    { "<leader>cA", source_action, desc = "Source Action" },
    { "<leader>cc", vim.lsp.codelens.run, desc = "Run Codelens", mode = { "n", "v" } },
    { "<leader>cC", vim.lsp.codelens.refresh, desc = "Refresh & Display Codelens" },
    { { "<leader>cr", "<f2>" }, rename_rhs, desc = "Rename", expr = rename_is_expr },
  }

  for _, key in ipairs(keys) do
    local mode, lhs, rhs = key.mode, key[1], key[2]
    local opts = {}
    for k, v in pairs(key) do
      opts[k] = v
    end
    opts.buffer = buffer
    opts.mode, opts[1], opts[2], opts.cond = nil, nil, nil, nil
    map(mode or "n", lhs, rhs, opts)
  end
end

return M
