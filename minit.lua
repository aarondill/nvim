---Copy to . and put specs into the bottom
---Usage: nvim -u ./minit.lua
vim.env.LAZY_STDPATH = ".repro"

vim.env.LAZY_OFFLINE = vim.uv.fs_lstat(vim.env.LAZY_STDPATH) and 1 -- Don't auto update plugins after first install
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()

vim.g.mapleader = " "
vim.cmd("nmap <leader>qq <cmd>q!<cr>")
vim.cmd("nmap <leader>wq <cmd>wq<cr>")

-- go to last visited line when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
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

require("lazy.minit").repro({
  ---@type LazySpec
  spec = {
    -- Put specs here
  },
})
