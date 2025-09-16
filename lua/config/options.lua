-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local o, g = vim.o, vim.g

--- This has to be set before loading lazy
g.mapleader = vim.keycode("<Space>")
g.maplocalleader = vim.keycode("<Space>")

-- Allows you to re-use the same window and switch from an unsaved buffer
-- without saving it first. Also allows you to keep an undo history for
-- multiple files when re-using the same window in this way. Vim will complain
-- if you try to quit without saving, and swap files will keep you safe if your
-- computer crashes.
o.hidden = true

-- Better command-line completion
o.wildmenu = true

-- Show partial commands in the last line of the screen
o.showcmd = true

-- Highlight searches (use <C-L> to temporarily turn off highlighting
o.hlsearch = true

-- When soft-wrapping lines, break at word boundaries
o.linebreak = true

-- Use case insensitive search, except when using capital letters
o.ignorecase = true
o.smartcase = true

-- When opening a new line and no filetype-specific indenting is enabled, keep
-- the same indent as the line you're currently on. Useful for READMEs, etc.
o.autoindent = true
-- Stop certain movements from always going to the first character of a line.
-- While this behaviour deviates from that of Vi, it does what most users
-- coming from other editors would expect.
o.startofline = false

o.ruler = true -- Display the cursor position on the last line of the screen or in the status line of a window
o.backspace = "indent,eol,start" -- Allow backspacing over autoindent, line breaks and start of insert action
o.laststatus = 2 -- Always display the status line, even if only one window is displayed
o.visualbell = true -- Use visual bell instead of beeping when doing something wrong
o.cmdheight = 2 -- Set the command window height to 2 lines, to avoid many cases of having to press <Enter> to continue"
o.number = true -- Display line numbers on the left
o.relativenumber = true -- Display numbers relative to the curser
-- o.pastetoggle = "<F11>" -- Use <F11> to toggle between 'paste' and 'nopaste'
o.updatetime = 100 -- Decrease updatetime for vim-gitgutter. Impacts swp file delay.
o.scrolloff = 5 -- Auto-scroll up or down to keep context above/below cursor
o.wrap = false -- turn off word-wrap
o.sidescrolloff = 5 -- Auto-scroll L/R to keep context in view
o.sidescroll = 1 -- Improve scrolling with nowrap
o.foldmethod = "marker" -- Set the fold method to obey comments
o.incsearch = true -- Turn on incremenetal search in vim
o.autowrite = false -- Disable auto write

-- Instead of failing a command because of unsaved changes, instead raise a
-- dialogue asking if you wish to save changed files.
o.confirm = true
-- And reset the terminal code for the visual bell. If visualbell is set, and
-- this line is also included, vim will neither flash nor beep. If visualbell
-- is unset, this does nothing.
o.vb = false

--Never time out on mappings
o.timeout = true
o.timeoutlen = 1000
-- o.timeout = false

-- Quickly time out on keycodes
o.ttimeout = true
o.ttimeoutlen = 40

-- Set tab and >> to be 2 spaces
o.shiftwidth = 2
o.softtabstop = 2
o.expandtab = true

-- Use s/match/sub/g by default
o.gdefault = true

local root_safe = require("utils.root_safe")
if root_safe then
  local dir = vim.env.HOME .. "/.cache/vimtmp"
  if not vim.fn.isdirectory(dir) then vim.fn.mkdir(dir, "p") end
  o.directory = dir -- Move the swap file
end

-- Reset to default value
if vim.fn.executable("rg") == 1 then
  o.grepprg = "rg --vimgrep --smart-case --hidden"
  o.grepformat = "%f:%l:%c:%m"
end

-- Disable providers
g.loaded_python3_provider = 0
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0

---Apparetly the tty has issues when the title is set. The screen goes blank.
o.title = not require("utils").is_tty()
o.titlestring = "nvim: %t %a%r%m"
-- HACK: This is a reasonable title to set, but we should be able to restore the previous.
o.titleold = vim.uv.os_get_passwd().username .. ": " .. vim.fn.fnamemodify(vim.uv.cwd() or "", ":~") ---@diagnostic disable-line: assign-type-mismatch

--- Disable checking for capital letters at start of sentance (this is frustrating in git commit messages)
o.spellcapcheck = ""

g.autoformat = true -- Enable LazyVim auto format

o.foldlevel = 99
o.clipboard = "unnamedplus" -- Sync with system clipboard
o.completeopt = "menu,menuone,noselect"
o.conceallevel = 2 -- Hide * markup for bold and italic, but not markers with substitutions
o.cursorline = true -- Enable highlighting of the current line
o.formatoptions = "jcroqlnt" -- tcqj
o.inccommand = "nosplit" -- preview incremental substitute
o.list = true -- Show some invisible characters (tabs...
o.mouse = "a" -- Enable mouse mode
o.pumblend = 10 -- Popup blend
o.pumheight = 10 -- Maximum number of entries in a popup
o.shiftround = true -- Round indent
o.showmode = false -- Dont show mode since we have a statusline
o.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
o.smartindent = true -- Insert indents automatically
o.spelloptions = "camel"
o.spelllang = "en"
o.splitbelow = true -- Put new windows below current
o.sessionoptions = "buffers,curdir,tabpages,winsize,help,globals,skiprtp,folds"
o.splitkeep = "screen"
o.splitright = true -- Put new windows right of current
o.tabstop = 2 -- Number of spaces tabs count for
o.termguicolors = true -- True color support
o.undofile = true
o.undolevels = 10000
o.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
o.wildmode = "longest:full,full" -- Command-line completion mode
o.winminwidth = 5 -- Minimum window width
---TODO: Use vim.o when it supports this syntax
---See: https://github.com/neovim/neovim/issues/20107
vim.opt.fillchars = {
  foldopen = "",
  foldclose = "",
  -- fold = "⸱",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}
vim.opt.shortmess:append({ W = true, I = true, c = true, C = true })
