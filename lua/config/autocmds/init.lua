local consts = require("consts")
local create_autocmd = require("utils.create_autocmd")
local map = require("utils.map")
local notifications = require("utils.notifications")
vim.g.netrw_dirhistmax = 0 -- Stop recording of dir history

local augroup = vim.api.nvim_create_augroup("vimrc_autocmds", { clear = true })

-- Check if we need to reload the file when it changed
create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, function()
  if vim.o.buftype == "nofile" then return end
  return vim.cmd.checktime()
end, { group = augroup })
-- Highlight on yank
create_autocmd("TextYankPost", function() return vim.highlight.on_yank() end, { group = augroup })
-- resize splits if window got resized
create_autocmd({ "VimResized" }, function()
  local current_tab = vim.fn.tabpagenr()
  vim.cmd("tabdo wincmd =")
  vim.cmd("tabnext " .. current_tab)
end, { group = augroup })

create_autocmd("FileType", "setlocal formatoptions-=c formatoptions-=r formatoptions-=o", {
  desc = "Disable auto-comments",
  group = augroup,
})
create_autocmd("VimLeavePre", "sleep 50m", "hack to work around Neovim bug #21856", { group = augroup })
-- resize splits if window got resized
create_autocmd({ "VimResized" }, function()
  local current_tab = vim.fn.tabpagenr()
  vim.cmd("tabdo wincmd =")
  vim.cmd("tabnext " .. current_tab)
end, { group = augroup })

-- go to last visited line when opening a buffer
create_autocmd("BufReadPost", function(event)
  local exclude = { "gitcommit" }
  local buf = event.buf ---@type integer
  if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].has_jumped_last_known_line then return end
  vim.b[buf].has_jumped_last_known_line = true
  local mark = vim.api.nvim_buf_get_mark(buf, '"')
  local lcount = vim.api.nvim_buf_line_count(buf)
  if mark[1] < 0 or mark[1] > lcount then return end
  pcall(vim.api.nvim_win_set_cursor, 0, mark)
end, { group = augroup })

-- close some filetypes with <q>
create_autocmd("FileType", function(event)
  vim.bo[event.buf].buflisted = false
  map("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
end, { group = augroup, pattern = consts.close_on_q })
-- make it easier to close man-files when opened inline
create_autocmd("FileType", function(event) vim.bo[event.buf].buflisted = false end, {
  group = augroup,
  pattern = { "man" },
})
-- Fix conceallevel for json files
create_autocmd({ "FileType" }, "setlocal conceallevel=0", { group = augroup, pattern = { "json", "jsonc", "json5" } })
-- Auto create dir when saving a file, in case some intermediate directory does not exist
create_autocmd({ "BufWritePre" }, function(event)
  if event.match:match("^%w%w+://") then return end
  local file = vim.loop.fs_realpath(event.match) or event.match
  return vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
end, "Create directories while saving", { group = augroup })

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

create_autocmd("User", function()
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
end, "Load documentation for lazyloaded plugins", { pattern = "VeryLazy", group = augroup, once = true })
create_autocmd("User", function(ev)
  local name = ev.data
  local datapath = vim.fn.stdpath("data") --[[@as string]]
  local doc_path = vim.fs.joinpath(datapath, "doc")
  local dir = vim.fs.joinpath(doc_path, name)
  if vim.fn.isdirectory(dir) ~= 1 then return end

  ---- This is disabled because it breaks multiple instances!
  -- assert(vim.fn.delete(dir, "rf") == 0, "failed to rm doc_path")
  vim.opt.rtp:remove(dir)
end, "Unload documentation when lazy loading plugins", { pattern = "LazyLoad", group = augroup })

create_autocmd({ "FileType" }, function()
  vim.b.spell = true
  vim.api.nvim_win_set_cursor(0, { 1, 0 }) -- go to top line
end, { pattern = { "gitcommit", "gitrebase" }, group = augroup })
create_autocmd("FileType", "setlocal wrap spell", { group = augroup, pattern = { "gitcommit", "markdown" } })

create_autocmd("BufHidden", function(event)
  if event.file ~= "" or vim.bo[event.buf].buftype ~= "" then return end
  if vim.bo[event.buf].modified then return end
  return vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(event.buf) then return end
    return vim.api.nvim_buf_delete(event.buf, {})
  end)
end, { desc = "Delete [No Name] buffers", group = augroup })

create_autocmd("BufWritePre", function(ev)
  if vim.uv.fs_stat(ev.file) then return end -- this file already exists, don't do this
  create_autocmd("BufWritePost", function(event)
    local shebang = vim.api.nvim_buf_get_lines(event.buf, 0, 1, true)[1]
    if not shebang or not shebang:match("^#!.+") then return end
    local fileinfo = vim.uv.fs_stat(event.file)
    -- If it's already executable, stop
    if not fileinfo or bit.band(fileinfo.mode - 32768, 0x40) ~= 0 then return end
    assert(vim.uv.fs_chmod(event.file, bit.bor(fileinfo.mode, 493)))
    notifications.info("Buffer set executable")
  end, { buffer = ev.buf, once = true })
end, { desc = "Set files with a she-bang as executable", group = augroup })

--- Read-only files should be non-modifiable.
create_autocmd("BufRead", function(ev)
  if vim.bo[ev.buf].buftype ~= "" then return end -- only on files
  vim.bo[ev.buf].modifiable = not vim.bo[ev.buf].readonly
end, { desc = "Make read-only files non-modifiable", group = augroup })

create_autocmd({ "BufEnter", "TermOpen" }, function(e)
  if vim.bo[e.buf].buftype ~= "terminal" then return end
  vim.cmd.startinsert()
end, { desc = "Enter terminal mode when entering a terminal buffer", group = augroup })

create_autocmd("BufNewFile", function(e)
  local extension = vim.fn.fnamemodify(e.file, ":e")
  if extension == "" then return end
  local template = vim.fs.joinpath(vim.fn.stdpath("config"), "templates", "skeleton." .. extension)
  if vim.fn.filereadable(template) == 0 then return end -- Return if template does not exist
  vim.cmd("silent! 0r " .. vim.fn.fnameescape(template))
end, { desc = "Template when opening a new file", group = augroup })

local this = ...
require("lazy.core.util").lsmod(this, function(mod)
  if mod == this then return end
  return require(mod)
end)
