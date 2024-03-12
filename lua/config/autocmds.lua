local notifications = require("utils.notifications")
-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
local api = vim.api
local NEW_BUF_EVENTS = { "BufReadPost", "BufNewFile" }
local VimRCAutoCmds = api.nvim_create_augroup("VimRCAutoCmds", { clear = true })
-- Stop recording of dir history
vim.g.netrw_dirhistmax = 0
-- Change .conf syntax highlighting to an aproximate
api.nvim_create_autocmd(NEW_BUF_EVENTS, {
  desc = "Change .conf syntax highlighting to an aproximate",
  group = VimRCAutoCmds,
  pattern = "*.conf",
  command = "set syntax=dosini",
})
-- Change .pluto to .lua
api.nvim_create_autocmd(NEW_BUF_EVENTS, {
  desc = "Change .pluto to .lua filetype",
  group = VimRCAutoCmds,
  pattern = "*.pluto",
  command = "set ft=lua",
})

-- Disable auto-comments!!!
api.nvim_create_autocmd("FileType", {
  desc = "Disable auto-comments",
  group = VimRCAutoCmds,
  pattern = "*",
  command = "setlocal formatoptions-=c formatoptions-=r formatoptions-=o",
})

api.nvim_create_autocmd(NEW_BUF_EVENTS, {
  pattern = "*.tmpl",
  group = VimRCAutoCmds,
  callback = function(ev)
    ---@type string
    local file = ev.file or ""
    local ext, count = file:sub(2):gsub(".+%.(.+).tmpl$", "%1")
    if count == 0 then return notifications.warn("Could not determine template extension for " .. file) end
    vim.opt.filetype = ext
  end,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
  desc = "hack to work around Neovim bug",
  pattern = "*",
  group = VimRCAutoCmds,
  callback = function()
    -- HACK: Work around https://github.com/neovim/neovim/issues/21856
    -- causing exit code 134 on :wq
    vim.cmd.sleep({ args = { "1m" } })
  end,
})

---------------------------------------------------------------
---------------------------------------------------------------
-------------------- Loading Docs into RTP --------------------
---------------------------------------------------------------
---------------------------------------------------------------

---@param src string the plugin dir (not /doc!)
---@param dest string the destination directory (without plugin name)
local function lndoc(src, dest)
  local src_doc = vim.fs.joinpath(src, "doc")
  if not vim.uv.fs_access(src_doc .. "/", "W") then return nil end
  local name = assert(vim.fs.basename(src))
  local dest_dir = vim.fs.joinpath(dest, name)
  local dest_doc = vim.fs.joinpath(dest_dir, "doc")
  vim.fn.mkdir(dest_dir, "p") -- throws on fail

  local stat = vim.uv.fs_stat(dest_doc)
  if not stat or stat.type ~= "link" or vim.uv.fs_readlink(dest_doc) ~= src_doc then
    vim.fn.delete(dest_doc, "rf")
    assert(vim.uv.fs_symlink(src_doc, dest_doc))
  end
  vim.cmd.helptags(dest_doc)
  vim.opt.rtp:append(dest_dir)
end

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  group = VimRCAutoCmds,
  desc = "Load documentation for lazyloaded plugins",
  once = true,
  callback = function()
    local datapath = vim.fn.stdpath("data") --[[@as string]]
    local doc_path = vim.fs.joinpath(datapath, "doc")
    local lazypath = vim.fs.joinpath(datapath, "lazy")

    -- Remove old doc directories/files.
    if vim.fn.isdirectory(doc_path) == 1 then
      for name in vim.fs.dir(doc_path) do
        local lazydoc = vim.fs.joinpath(lazypath, name, "doc")
        local docdoc = vim.fs.joinpath(doc_path, name)
        if vim.fn.isdirectory(lazydoc) ~= 1 then vim.fn.delete(docdoc, "rf") end
      end
    end

    -- Copy documentation to the opt_docs directory and generate helptags
    for name in vim.fs.dir(lazypath) do
      lndoc(vim.fs.joinpath(lazypath, name), doc_path)
    end
  end,
})
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyLoad",
  group = VimRCAutoCmds,
  desc = "Unload documentation when lazy loading plugins",
  callback = function(ev)
    local name = ev.data
    local datapath = vim.fn.stdpath("data") --[[@as string]]
    local doc_path = vim.fs.joinpath(datapath, "doc")
    local dir = vim.fs.joinpath(doc_path, name)
    if vim.fn.isdirectory(dir) ~= 1 then return end

    ---- This is disabled because it breaks multiple instances!
    -- assert(vim.fn.delete(dir, "rf") == 0, "failed to rm doc_path")
    vim.opt.rtp:remove(dir)
  end,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "gitcommit", "gitrebase" },
  group = VimRCAutoCmds,
  callback = function()
    vim.b.spell = true
    vim.api.nvim_win_set_cursor(0, { 1, 0 }) -- go to top line
    vim.cmd.startinsert() -- start in insert mode
  end,
})
