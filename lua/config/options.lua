-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local opt = vim.opt

--- This has to be set before loading lazy
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Allows you to re-use the same window and switch from an unsaved buffer
-- without saving it first. Also allows you to keep an undo history for
-- multiple files when re-using the same window in this way. Vim will complain
-- if you try to quit without saving, and swap files will keep you safe if your
-- computer crashes.
opt.hidden = true

opt.wildmenu = true -- Better command-line completion

opt.showcmd = true -- Show partial commands in the last line of the screen

opt.hlsearch = true -- Highlight searches (use <C-L> to temporarily turn off highlighting

-- Use case insensitive search, except when using capital letters
opt.ignorecase = true
opt.smartcase = true

-- When opening a new line and no filetype-specific indenting is enabled, keep
-- the same indent as the line you're currently on. Useful for READMEs, etc.
opt.autoindent = true
-- Stop certain movements from always going to the first character of a line.
-- While this behaviour deviates from that of Vi, it does what most users
-- coming from other editors would expect.
opt.startofline = false

opt.ruler = true -- Display the cursor position on the last line of the screen or in the status line of a window
opt.backspace = "indent,eol,start" -- Allow backspacing over autoindent, line breaks and start of insert action
opt.laststatus = 2 -- Always display the status line, even if only one window is displayed
opt.visualbell = true -- Use visual bell instead of beeping when doing something wrong
opt.cmdheight = 2 -- Set the command window height to 2 lines, to avoid many cases of having to press <Enter> to continue"
opt.number = true -- Display line numbers on the left
opt.relativenumber = true -- Display numbers relative to the curser
-- opt.pastetoggle = "<F11>" -- Use <F11> to toggle between 'paste' and 'nopaste'
opt.updatetime = 100 -- Decrease updatetime for vim-gitgutter. Impacts swp file delay.
opt.scrolloff = 5 -- Auto-scroll up or down to keep context above/below cursor
opt.wrap = false -- turn off word-wrap
opt.sidescrolloff = 5 -- Auto-scroll L/R to keep context in view
opt.sidescroll = 1 -- Improve scrolling with nowrap
opt.foldmethod = "marker" -- Set the fold method to obey comments
opt.incsearch = true -- Turn on incremenetal search in vim
opt.autowrite = false -- Disable auto write

-- Instead of failing a command because of unsaved changes, instead raise a
-- dialogue asking if you wish to save changed files.
opt.confirm = true
-- And reset the terminal code for the visual bell. If visualbell is set, and
-- this line is also included, vim will neither flash nor beep. If visualbell
-- is unset, this does nothing.
opt.vb = false

--Never time out on mappings
opt.timeout = true
opt.timeoutlen = 300
-- opt.timeout = false

-- Quickly time out on keycodes
opt.ttimeout = true
opt.ttimeoutlen = 40

-- Set tab and >> to be 2 spaces
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true

-- Use s/match/sub/g by default
opt.gdefault = true

local root_safe = require("utils.root_safe")
if root_safe then
  local dir = vim.env.HOME .. "/.cache/vimtmp"
  if not vim.fn.isdirectory(dir) then vim.fn.mkdir(dir, "p") end
  opt.directory = dir -- Move the swap file
end

-- Reset to default value
if vim.fn.executable("rg") then
  opt.grepprg = "rg --vimgrep --smart-case --hidden"
  opt.grepformat = "%f:%l:%c:%m"
end

-- Disable providers
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

opt.title = true
opt.titlestring = "nvim: %t %a%r%m"
-- HACK: This is a reasonable title to set, but we should be able to restore the previous.
opt.titleold = vim.loop.os_get_passwd().username .. ": " .. vim.fn.fnamemodify(vim.loop.cwd(), ":~") ---@diagnostic disable-line: assign-type-mismatch

--- Disable checking for capital letters at start of sentance (this is frustrating in git commit messages)
opt.spellcapcheck = ""

vim.g.autoformat = true -- Enable LazyVim auto format

-- LazyVim root dir detection
-- Each entry can be:
-- * the name of a detector function like `lsp` or `cwd`
-- * a pattern or array of patterns like `.git` or `lua`.
-- * a function with signature `function(buf) -> string|string[]`
vim.g.root_spec = require("consts").lazy_root_spec

vim.opt.foldlevel = 99
opt.clipboard = "unnamedplus" -- Sync with system clipboard
opt.completeopt = "menu,menuone,noselect"
opt.conceallevel = 2 -- Hide * markup for bold and italic, but not markers with substitutions
opt.cursorline = true -- Enable highlighting of the current line
opt.formatoptions = "jcroqlnt" -- tcqj
opt.inccommand = "nosplit" -- preview incremental substitute
opt.list = true -- Show some invisible characters (tabs...
opt.mouse = "a" -- Enable mouse mode
opt.pumblend = 10 -- Popup blend
opt.pumheight = 10 -- Maximum number of entries in a popup
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.shiftround = true -- Round indent
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.showmode = false -- Dont show mode since we have a statusline
opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
opt.smartindent = true -- Insert indents automatically
opt.spelloptions = "camel"
opt.spelllang = { "en" }
opt.splitbelow = true -- Put new windows below current
opt.splitkeep = "screen"
opt.splitright = true -- Put new windows right of current
opt.tabstop = 2 -- Number of spaces tabs count for
opt.termguicolors = true -- True color support
opt.undofile = true
opt.undolevels = 10000
opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
opt.wildmode = "longest:full,full" -- Command-line completion mode
opt.winminwidth = 5 -- Minimum window width
opt.fillchars = {
  foldopen = "",
  foldclose = "",
  -- fold = "⸱",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}
