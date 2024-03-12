local consts = require("consts")
local map = require("utils.set_key_map")
vim.g.netrw_dirhistmax = 0 -- Stop recording of dir history

local augroup = vim.api.nvim_create_augroup("vimrc_autocmds", { clear = true })

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup,
  callback = function()
    if vim.o.buftype == "nofile" then return end
    return vim.cmd.checktime()
  end,
})
-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function() return vim.highlight.on_yank() end,
})
-- resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
  group = augroup,
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Disable auto-comments",
  group = augroup,
  command = "setlocal formatoptions-=c formatoptions-=r formatoptions-=o",
})
vim.api.nvim_create_autocmd("VimLeavePre", {
  desc = "hack to work around Neovim bug #21856",
  group = augroup,
  callback = function() return vim.cmd.sleep({ args = { "50m" } }) end,
})
-- resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
  group = augroup,
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- go to last visited line when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf ---@type integer
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].has_jumped_last_known_line then return end
    vim.b[buf].has_jumped_last_known_line = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] < 0 or mark[1] > lcount then return end
    pcall(vim.api.nvim_win_set_cursor, 0, mark)
  end,
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = consts.close_on_q,
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    map("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})
-- make it easier to close man-files when opened inline
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "man" },
  callback = function(event) vim.bo[event.buf].buflisted = false end,
})
-- Fix conceallevel for json files
vim.api.nvim_create_autocmd({ "FileType" }, {
  group = augroup,
  pattern = { "json", "jsonc", "json5" },
  callback = function() vim.opt_local.conceallevel = 0 end,
})
-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = augroup,
  callback = function(event)
    if event.match:match("^%w%w+://") then return end
    local file = vim.loop.fs_realpath(event.match) or event.match
    return vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
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
  group = augroup,
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
  group = augroup,
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
  group = augroup,
  callback = function()
    vim.b.spell = true
    vim.api.nvim_win_set_cursor(0, { 1, 0 }) -- go to top line
    vim.cmd.startinsert() -- start in insert mode
  end,
})
-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})
