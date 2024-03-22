local get_vtext = require("utils.vtext")
local map = require("utils.map")
local notifications = require("utils.notifications")
local root = require("utils.root")
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

-- map up/down to move over screen lines instead of file lines (only matters with 'wrap')
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
-- Move to window using the <ctrl> hjkl keys
map("n", "<C-h>", "<C-w>h", "Go to left window", { remap = true })
map("n", "<C-j>", "<C-w>j", "Go to lower window", { remap = true })
map("n", "<C-k>", "<C-w>k", "Go to upper window", { remap = true })
map("n", "<C-l>", "<C-w>l", "Go to right window", { remap = true })
map("t", "<C-h>", "<cmd>wincmd h<cr>", "Go to left window")
map("t", "<C-j>", "<cmd>wincmd j<cr>", "Go to lower window")
map("t", "<C-k>", "<cmd>wincmd k<cr>", "Go to upper window")
map("t", "<C-l>", "<cmd>wincmd l<cr>", "Go to right window")
-- Resize window using <ctrl> arrow keys
map("n", "<C-Up>", "<cmd>resize +2<cr>", "Increase window height")
map("n", "<C-Down>", "<cmd>resize -2<cr>", "Decrease window height")
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", "Decrease window width")
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", "Increase window width")
-- Move Lines
---TODO: can this be merged together?
map("n", "<A-j>", "<cmd>m .+1<cr>==", "Move down")
map("n", "<A-k>", "<cmd>m .-2<cr>==", "Move up")
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", "Move up")
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", "Move down")
map("v", "<A-j>", ":m '>+1<cr>gv=gv", "Move down")
map("v", "<A-k>", ":m '<-2<cr>gv=gv", "Move up")
-- buffers
map("n", { "<S-h>", "[b" }, "<cmd>bprevious<cr>", "Prev buffer")
map("n", { "<S-l>", "]b" }, "<cmd>bnext<cr>", "Next buffer")
-- Clear search with <esc>
map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", "Escape and clear hlsearch")
-- Add undo break-points
for _, k in ipairs({ ",", ".", ";" }) do
  map("i", k, k .. "<c-g>u")
end
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", "Save file")
map("n", "<leader>l", "<cmd>Lazy<cr>", "Lazy")
map("n", "<leader>fn", "<cmd>enew<cr>", "New File")
map("n", "[q", vim.cmd.cprev, "Previous quickfix")
map("n", "]q", vim.cmd.cnext, "Next quickfix")
map({ "n", "v" }, "<leader>cf", require("utils.format").format, "Format")
-- diagnostic
map("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")
map("n", "[d", vim.diagnostic.goto_prev, "Prev Diagnostic")
-- toggle options

---@param silent boolean?
---@param values? {[1]:any, [2]:any}
---@return fun() toggler the function to toggle the given option
local function toggle_option(option, values, silent)
  silent, values = silent or false, values or { true, false }
  return function()
    local new_value = values[1]
    if vim.opt_local[option]:get() == values[1] then new_value = values[2] end
    vim.opt_local[option] = new_value
    if silent then return end -- Don't notify!
    local msg = (new_value == true and "Enabled %s") or (new_value == false and "Disabled %s") or "Set %s to %s"
    return notifications.info(msg:format(option, new_value), { title = "Option" })
  end
end
---@return fun() toggler the function to toggle diagnostics
local function toggle_diagnostics(buffer_local) ---@param buffer_local boolean?
  -- if this Neovim version supports checking if diagnostics are enabled then use that for the current state
  if not vim.diagnostic.is_disabled then
    return function()
      return notifications.warn({
        "Toggling diagnostics is unsupported when vim.diagnostic.is_disabled is nil.",
        "Call vim.diagnostic.enable() or vim.diagnostic.disable() to control them.",
      })
    end
  end
  return function()
    local enable = vim.diagnostic.is_disabled()
    local f = enable and vim.diagnostic.enable or vim.diagnostic.disable
    local msg = enable and "Enabled diagnostics" or "Disabled diagnostics"
    f(buffer_local and 0 or nil)
    return notifications.info(msg, { title = "Diagnostics" })
  end
end
local function toggle_inlay_hints()
  if not vim.lsp.inlay_hint then return notifications.warn("This NeoVim version doesn't have inlay_hint support!") end
  return vim.lsp.inlay_hint.enable(0, not vim.lsp.inlay_hint.is_enabled())
end

map("n", "<leader>uf", require("utils.format").toggle, "Toggle auto format (global)")
map("n", "<leader>uF", function() return require("utils.format").toggle(true) end, "Toggle auto format (buffer)")
map("n", "<leader>us", toggle_option("spell"), "Toggle Spelling")
map("n", "<leader>uw", toggle_option("wrap"), "Toggle Word Wrap")
map("n", "<leader>uL", toggle_option("relativenumber"), "Toggle Relative Line Numbers")
map("n", "<leader>ud", toggle_diagnostics(), "Toggle Diagnostics (global)")
map("n", "<leader>uD", toggle_diagnostics(true), "Toggle Diagnostics (buffer)")
local conceallevel = vim.o.conceallevel > 0 and vim.o.conceallevel or 3
map("n", "<leader>uc", toggle_option("conceallevel", { 0, conceallevel }), "Toggle Conceal")
map("n", "<leader>uh", toggle_inlay_hints, "Toggle Inlay Hints")
map("n", "<leader>uT", function()
  local f = vim.b.ts_highlight and vim.treesitter.stop or vim.treesitter.start
  return f()
end, "Toggle Treesitter Highlight")
local lg = function() return require("utils.terminal").open("lazygit", { esc_esc = false, ctrl_hjkl = false }) end
map("n", "<leader>gg", lg, "Lazygit")
map("n", "<leader>gf", function()
  if not vim.fn.executable("git") then return notifications.warn("git is not installed!") end
  local pres = vim.system({ "git", "ls-files", "--full-name", vim.api.nvim_buf_get_name(0) }):wait()
  local git_path = assert(pres.stdout, "stdout is not present")
  require("utils.terminal").open({ "lazygit", "-f", vim.trim(git_path) }, { esc_esc = false, ctrl_hjkl = false })
end, { desc = "Lazygit current file history" })
-- windows
map("n", "<leader>ww", "<C-W>p", "Other window", { remap = true })
map("n", "<leader>wd", "<C-W>c", "Delete window", { remap = true })
map("n", { "<leader>-", "<leader>w-" }, "<C-W>s", "Split window below", { remap = true })
map("n", { "<leader>|", "<leader>w|" }, "<C-W>v", "Split window right", { remap = true })

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
map("n", "<leader>qq", "<cmd>qa<cr>", "Quit all")
map("n", "<leader>wq", function()
  local should_write = vim.o.bt:len() == 0 and vim.o.modifiable and not vim.readonly
  return should_write and "<cmd>wq<cr>" or "<cmd>q<cr>"
end, "Save and exit", { expr = true })

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
map({ "c", "i", "n", "x" }, { "<C-v>", "<leader>p" }, function()
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
  if not current_line or current_line:match("^%s*$") then return "<Tab>" end

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

-- floating terminal
---@param root_dir boolean?
local term = function(root_dir)
  return function()
    local t = require("utils.terminal").open(nil, { cwd = root_dir and root.get() or nil })
    map({ "t", "n" }, "<C-CR>", function() t:hide() end, { buffer = t.buf, nowait = true })
  end
end
map("n", { "<C-CR>", "<Leader><CR>" }, term(true), "Terminal (root dir)")
map("n", { "<S-CR>", "<Leader><S-CR>" }, term(false), "Terminal (cwd dir)")

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

map("i", "<c-a>", "<c-o>^", "Beginning of line")
map("i", "<c-e>", "<End>", "End of line")
map("c", "<c-a>", "<Home>", "Beginning of line")
map("c", "<c-e>", "<End>", "End of line")

map("i", "<tab>", function()
  if package.loaded["tabnine"] and require("tabnine.keymaps").accept_suggestion then
    if require("tabnine.keymaps").accept_suggestion() then return end
  end
  if package.loaded["luasnip"] then
    if require("luasnip").jump(1) then return end
  end
  vim.api.nvim_feedkeys("\t", "n", false)
end, "Tab completion in insert mode")
