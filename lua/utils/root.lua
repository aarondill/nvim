local notifications = require("utils.notifications")

local is_win = vim.loop.os_uname().sysname:find("Windows") ~= nil

---@overload fun(): string
local M = setmetatable({}, { __call = function(m) return m.get() end })

---@type table<number, string>
M.cache = {}

---@class Root
---@field paths string[]
---@field spec RootSpec

---@alias RootFn fun(buf: number): (string|string[])

---@alias RootSpec string|string[]|RootFn

---@type RootSpec[]
M.spec = { "lsp", require("consts").root_markers, "cwd" }

M.detectors = {}

function M.detectors.cwd() return { vim.loop.cwd() } end

local function realpath(path)
  if path == "" or path == nil then return nil end
  local rpath = vim.loop.fs_realpath(path)
  return vim.fs.normalize(rpath or path, { expand_env = false })
end
local function bufpath(buf) return realpath(vim.api.nvim_buf_get_name(assert(buf))) end

function M.detectors.lsp(buf)
  local bpath = bufpath(buf)
  if not bpath then return {} end
  local roots = {} ---@type string[]
  -- only check workspace folders, since we're not interested in clients running in single file mode
  for _, client in pairs(vim.lsp.get_clients({ bufnr = buf })) do
    for _, ws in pairs(client.config.workspace_folders or {}) do
      roots[#roots + 1] = vim.uri_to_fname(ws.uri)
    end
  end
  return vim.tbl_filter(function(path)
    path = realpath(path)
    if not path then return false end
    return vim.startswith(bpath, path)
  end, roots)
end

---@param patterns string[]|string
function M.detectors.pattern(buf, patterns)
  patterns = type(patterns) == "string" and { patterns } or patterns
  local path = bufpath(buf) or vim.loop.cwd()
  local pattern = vim.fs.find(patterns, { path = path, upward = true })[1]
  if not pattern then return {} end
  return { vim.fs.dirname(pattern) }
end

---@param spec RootSpec
---@return RootFn
function M.resolve(spec)
  if M.detectors[spec] then return M.detectors[spec] end
  if type(spec) == "function" then return spec end
  return function(buf) return M.detectors.pattern(buf, spec) end
end

---@param opts? { buf?: number, spec?: RootSpec[], all?: boolean }
function M.detect(opts)
  opts = opts or {}
  opts.spec = opts.spec or type(vim.g.root_spec) == "table" and vim.g.root_spec or M.spec
  opts.buf = (opts.buf == nil or opts.buf == 0) and vim.api.nvim_get_current_buf() or opts.buf

  local ret = {} ---@type Root[]
  for _, spec in ipairs(opts.spec) do
    local paths = M.resolve(spec)(opts.buf)
    paths = paths or {}
    paths = type(paths) == "table" and paths or { paths }
    local roots = {} ---@type string[]
    for _, p in ipairs(paths) do
      local pp = M.realpath(p)
      if pp and not vim.tbl_contains(roots, pp) then roots[#roots + 1] = pp end
    end
    table.sort(roots, function(a, b) return #a > #b end)
    if #roots > 0 then
      ret[#ret + 1] = { spec = spec, paths = roots }
      if opts.all == false then break end
    end
  end
  return ret
end

function M.info()
  local roots = M.detect({ all = true })
  local lines = {} ---@type string[]
  local first = true
  for _, root in ipairs(roots) do
    for _, path in ipairs(root.paths) do
      local root_spec = root.spec
      local spec_str = type(root_spec) == "table" and table.concat(root_spec, ", ") or tostring(root_spec)
      lines[#lines + 1] = ("- [%s] `%s` **(%s)**"):format(first and "x" or " ", path, spec_str)
      first = false
    end
  end
  vim.list_extend(lines, {
    "```lua",
    "M.spec = " .. vim.inspect(M.spec),
    "```",
  })
  notifications.info(lines, { title = "Roots" })
end

-- returns the root directory based on:
-- * lsp workspace folders
-- * lsp root_dir
-- * root pattern of filename of the current buffer
-- * root pattern of cwd
---@param opts? {normalize?:boolean}
---@return string
function M.get(opts)
  local buf = vim.api.nvim_get_current_buf()
  local ret = M.cache[buf]
  if not ret then
    local roots = M.detect({ all = false })
    ret = roots[1] and roots[1].paths[1] or vim.loop.cwd()
    M.cache[buf] = ret
  end
  if opts and opts.normalize then return ret end
  return is_win and ret:gsub("/", "\\") or ret
end

function M.git()
  local root = M.get()
  local git_dir = vim.fs.find(".git", { path = root, type = "directory", upward = true })[1]
  return git_dir and vim.fs.dirname(git_dir) or root
end

vim.api.nvim_create_user_command("RootInfo", M.info, { desc = "Roots for the current buffer" })
vim.api.nvim_create_autocmd({ "LspAttach", "BufWritePost", "DirChanged" }, {
  group = vim.api.nvim_create_augroup("root_cache", { clear = true }),
  callback = function(event) M.cache[event.buf] = nil end,
})

return M
