local get_vtext = require("utils.vtext")
local map = require("utils.set_key_map")
local notifications = require("utils.notifications")
local text = require("utils.text")
local function get_cursorline_contents() ---@return string?
  local linenr = vim.api.nvim_win_get_cursor(0)[1]
  return vim.api.nvim_buf_get_lines(0, linenr - 1, linenr, false)[1]
end

---Use in an expr mapping. Returns the mapping if the current line (or selected text) is not just whitespace
---@param input string
local function line_not_empty(input) ---@return fun(): string?
  return function()
    local vtext = get_vtext() or get_cursorline_contents()
    if not vtext then return end
    if not vtext:find("^%s*$") then return input end -- not empty
  end
end
local function toggle_movement(first, second) ---@return fun()
  first = vim.api.nvim_replace_termcodes(first, true, false, true) -- Allow <C-k> escapes
  second = vim.api.nvim_replace_termcodes(second, true, false, true)
  return function()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0), 1, 2)
    vim.api.nvim_feedkeys(first, "nx", false) -- run first -- note: 'x' is needed to ensure that it happens *now*
    local nrow, ncol = unpack(vim.api.nvim_win_get_cursor(0), 1, 2)
    if row ~= nrow or col ~= ncol then return end -- it moved!
    return vim.api.nvim_feedkeys(second, "n", false) -- run then
  end
end

map({ "i", "n" }, "<F3>", function()
  local cmd = vim.fn.getreg(":", 1) --[[@as string?]]
  if not cmd or cmd == "" then return notifications.error("No previous command line") end
  local ok, res = pcall(vim.api.nvim_exec2, cmd, { output = true })
  if not ok then return notifications.error(tostring(res)) end
  local output = res and res.output
  if not output then return end
  return text.insert(output, true)
end, "Insert last command output into buffer")

-- Change U to redo for symetry with u
map("n", "U", "<c-r>", "Redo")

--- Map Ctrl+Shift+A to decrement, since Ctrl+A is increment (and Ctrl+X is remapped later)
map("n", "<c-s-a>", "<c-x>", "Decrement")

-- Map Y to act like D and C, i.e. to yank until EOL, rather than act as yy,
-- which is the default
map("n", "Y", "y$", "Yank until EOL")

-- Quick save and quit
map("n", "<leader>wq", function()
  -- Save if possible
  local should_write = vim.o.bt:len() == 0 and vim.o.modifiable and not vim.readonly
  local cmd = should_write and vim.cmd.wq or vim.cmd.q
  local ok, err = pcall(cmd)
  if not ok then return notifications.error(err) end
end, "Save and exit")

-- Quick quit
map("n", "<leader>q!", vim.cmd.q, "Exit without saving")
-- Quit without shift
map("n", "<leader>q1", vim.cmd.q, "Exit without saving")

-- Terminal allow escape to exit insert
map("t", "<Esc>", "<C-\\><C-n>", "Exit insert")

-- Map 0 to go between 0 and ^
map({ "n", "x" }, "0", toggle_movement("^", "0"), "Go to start of line", { silent = true })
map({ "n", "x" }, "^", toggle_movement("0", "^"), "Go to start of line", { silent = true })
-- Map gg to go between gg and G
map({ "n", "x" }, "gg", toggle_movement("gg", "G"), "Go to start/end of file", { silent = true })
-- Map G to go between G and gg
map({ "n", "x" }, "G", toggle_movement("G", "gg"), "Go to start/end of file", { silent = true })

-- Remap f9 to fold control
map("i", "<F9>", "<C-O>za", "Toggle Fold")
map("n", "<F9>", "za", "Toggle Fold")
map("o", "<F9>", "<C-C>za", "Toggle Fold")
map("x", "<F9>", "zf", "Create Fold")

map("n", "<leader>ds", "<cmd>DiffSaved<cr>", "Show the [d]iff with last [s]ave")

-- Paste system clipboard with Ctrl + v
map({ "c", "i", "n", "x" }, "<C-v>", function()
  ---@diagnostic disable-next-line: redundant-parameter # this works, but the types are wrong
  local clip = vim.fn.getreg("+", 1, true)
  assert(type(clip) == "table", "getreg returned a string!")
  return vim.paste(clip, -1)
end, "Paste from system clipboard")

-- Cut to system clipboard with Ctrl + x
map("x", "<C-x>", line_not_empty('"+d'), "Cut to system clipboard", { expr = true })
map("n", "<C-x>", line_not_empty('"+dd'), "Cut to system clipboard", { expr = true })
map("i", "<C-x>", line_not_empty('<ESC>"+ddi'), "Cut to system clipboard", { expr = true })

-- Copy to system clipboard with Ctr + c
map("x", "<C-c>", line_not_empty('"+y'), "[C]opy to system clipboard", { expr = true })
map("n", "<C-c>", line_not_empty('"+yy'), "[C]opy to system clipboard", { expr = true })
map("i", "<C-c>", line_not_empty('<ESC>"+yya'), "[C]opy to system clipboard", { expr = true })

-- Cd shortcuts
map("n", "<Leader>cc", "<Cmd>cd! %:h<CR>", "[c]d to [c]urrent buffer path")
map("n", "<Leader>..", "<Cmd>cd! ..<CR>", "cd up a level [..]")

-- Edit closest
map("n", "<Leader>erm", function() require("utils.edit_closest")("README.md") end, "[E]dit closest [R]EAD[M]E.md")

map("n", "<Leader>epj", function() require("utils.edit_closest")("package.json") end, "[E]dit closest [p]ackage.[j]son")

map({ "i", "n" }, "<F1>", "<NOP>", "Disable help shortcut key")

map("n", "<Leader>yn", function()
  local res = vim.fn.expand("%:t")
  if not res or res == "" then
    return notifications.error("buffer has no filename", { title = "Failed to yank filename", render = "compact" })
  end
  vim.fn.setreg("+", res)
  return notifications.info(res, { title = "yanked filename" })
end, "Yank the filename of current buffer")

map("n", "<Leader>yp", function()
  local res = vim.fn.expand("%:p")
  res = res == "" and vim.loop.cwd() or res
  if not res or res == "" then return end
  vim.fn.setreg("+", res)
  return notifications.info(res, { title = "yanked filepath" })
end, "Yank the full filepath of current buffer")

map("x", "<", "<gv", "Reselect visual block after indent")
map("x", ">", ">gv", "Reselect visual block after indent")

-- Magic tab thingis - see https://github.com/davidosomething/dotfiles/blob/dev/nvim/lua/dko/mappings.lua#L215

map("i", "<Tab>", function()
  -- If characters all the way back to start of line were all whitespace,
  -- insert whatever expandtab setting is set to do.
  local current_line = get_cursorline_contents()
  if current_line:match("^%s*$") then return "<Tab>" end

  -- Insert appropriate amount of spaces instead of real tabs
  local sts = vim.bo.softtabstop <= 0 and vim.fn.shiftwidth() or vim.bo.softtabstop
  -- How many spaces to insert after the current cursor to get to the next sts
  local spaces_from_cursor_to_next_sts = vim.fn.virtcol(".") % sts
  if spaces_from_cursor_to_next_sts == 0 then spaces_from_cursor_to_next_sts = sts end

  -- Insert whitespace to next softtabstop
  -- E.g. sts = 4, cursor at _,
  --          1234123412341234
  -- before   abc_
  -- after    abc _
  -- before   abc _
  -- after    abc     _
  -- before   abc    _
  -- after    abc     _
  return (" "):rep(1 + sts - spaces_from_cursor_to_next_sts)
end, "Tab should insert spaces", { expr = true })

map("i", "<S-Tab>", "<C-d>", "Tab inserts a tab, shift-tab should remove it")

map({ "n", "x" }, "\\", "@:", "Backslash redoes the last command")

local lazyterm = function()
  local root = require("lazyvim.util.root")
  local terminal = require("lazyvim.util.terminal")
  return terminal.open(nil, { cwd = root.get() })
end
map("n", { "<C-CR>", "<Leader><CR>" }, lazyterm, "Terminal (root dir)")
map("t", "<C-CR>", lazyterm, "Terminal (root dir)")

map("x", "<F4>", function() end)
map("x", "<C-/>", function()
  -- If :Telescope command doesn't exist, call :grep instead
  if vim.fn.exists(":Telescope") == 2 then return "<Cmd>Telescope grep_string<Cr>" end
  return ":<C-u>grep <C-r><C-w>"
end, "Grep for the selected string", { expr = true })

map("n", "<bs>", function()
  if vim.fn.getreg("#") == "" then return "<cmd>bn<cr>" end
  return "<c-^>"
end, { silent = true, noremap = true, expr = true })

-- Allow scrolling through autocomplete with up and down arrows!
map("c", "<c-p>", "<up>")
map("c", "<c-n>", "<down>")
map("c", "<up>", "<c-p>")
map("c", "<down>", "<c-n>")

-- Use Ctrl+hjkl to move in insert mode!
map("i", "<c-h>", "<left>")
map("i", "<c-j>", "<down>")
map("i", "<c-k>", "<up>")
map("i", "<c-l>", "<right>")
