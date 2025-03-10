local notifications = require("utils.notifications")

local is_win = vim.loop.os_uname().sysname:find("Windows") ~= nil

---@overload fun(): string
local M = setmetatable({}, { __call = function(m) return m.get() end })

---@type table<number, string>
M.cache = {}

---@class Root
---@field paths string[]
---@field spec RootSpec

---@alias RootFn fun(buf: number): (string|string[]|nil)

---@alias RootSpec string|string[]|RootFn

---@type RootSpec[]
M.spec = {
  "lsp",
  "gitdir",
  "tmpsh",
  require("consts").root_markers,
  "cwd",
}

---@type table<string, RootFn>
M.detectors = {}

---@param path string
---@param must_exist? boolean (default: true) if true, returns nil if the path doesn't exist. Otherwise, returns the path *if* it's parent directory exists.
---@return string? rpath nil is returned if the path is empty
local function realpath(path, must_exist)
  if path == "" or path == nil then return nil end
  local rpath
  if must_exist == false then -- Only parent must exist, so join the realpath(dirname(p))/basename(p)
    local parent = vim.fs.dirname(path)
    local preal = vim.loop.fs_realpath(parent)
    if not preal then return nil end
    rpath = vim.fs.joinpath(preal, vim.fs.basename(path))
  else
    rpath = vim.loop.fs_realpath(path)
  end
  if not rpath then return nil end
  return vim.fs.normalize(rpath, { expand_env = false })
end
local function bufpath(buf) return realpath(vim.api.nvim_buf_get_name(assert(buf))) end

function M.detectors.cwd() return vim.loop.cwd() end

function M.detectors.gitdir(buf)
  local bdir = vim.fs.dirname(bufpath(buf))
  local o = vim.system({ "git", "rev-parse", "--show-toplevel" }, { cwd = bdir, stderr = false, timeout = 1000 }):wait()
  if o.code ~= 0 then return nil end
  return o.stdout
end

---A custom detector for detecting the root of a temporary shell
---Information here: ~/.local/bin/tmpsh
function M.detectors.tmpsh(buf)
  if vim.env.TMPSH ~= "1" then return {} end
  assert(vim.env.TMPSH_ROOT, "TMPSH_ROOT is not set")
  --- This must be a directory.
  local rpath = realpath(vim.env.TMPSH_ROOT)
  if not rpath then return nil end
  local bpath = bufpath(buf) or (vim.loop.cwd() .. "/")
  -- Add a trailing slash to make sure that startswith() works. realpath() returns a path without a trailing slash.
  return vim.startswith(bpath, rpath .. "/") and rpath or nil
end

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
    path = path and realpath(path)
    if not path then return false end
    return vim.startswith(bpath, path)
  end, roots)
end

---@param buf number
---@param patterns string[]|string
---@return string?
function M.pattern(buf, patterns)
  patterns = type(patterns) == "string" and { patterns } or patterns
  local path = bufpath(buf) or vim.loop.cwd()
  local pattern = vim.fs.find(patterns, { path = path, upward = true })[1]
  if not pattern then return nil end
  return vim.fs.dirname(pattern)
end

---@param spec RootSpec
---@return RootFn
function M.resolve(spec)
  if M.detectors[spec] then return M.detectors[spec] end
  if type(spec) == "function" then return spec end
  return function(buf) return M.pattern(buf, spec) end
end

---@param opts? { buf?: number, spec?: RootSpec[], all?: boolean }
function M.detect(opts)
  opts = opts or {}
  opts.spec = opts.spec or type(vim.g.root_spec) == "table" and vim.g.root_spec or M.spec
  opts.buf = (opts.buf == nil or opts.buf == 0) and vim.api.nvim_get_current_buf() or opts.buf

  local ret = {} ---@type Root[]
  for _, spec in ipairs(opts.spec) do
    local path = M.resolve(spec)(opts.buf) or {}
    local paths = type(path) == "table" and path or { path } ---@type string[]
    local roots = {} ---@type string[]
    for _, p in ipairs(paths) do
      local pp = realpath(p)
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
