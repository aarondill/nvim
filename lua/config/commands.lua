local notifications = require("utils.notifications")
local text = require("utils.text")

vim.api.nvim_create_user_command("DiffSaved", function()
  local filename = vim.api.nvim_buf_get_name(0)
  if filename == "" then return notifications.warn("Cannot diff empty filename!") end
  local filetype = vim.bo.ft
  vim.cmd.diffthis()

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, { vertical = true })
  local lines = vim.fn.readfile(filename) ---@type string[]
  vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)
  vim.api.nvim_win_set_cursor(win, { 1, 0 })
  vim.api.nvim_win_call(win, vim.cmd.diffthis)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].readonly = true
  vim.bo[buf].filetype = filetype
  vim.keymap.set("n", "q", vim.cmd.close, { buffer = buf })
end, {})

vim.api.nvim_create_user_command("RandomLine", function()
  local l = math.random(1, vim.fn.line("$") or 1) -- Get random number upto last line
  local col = vim.api.nvim_win_get_cursor(0)[2]
  return vim.api.nvim_win_set_cursor(0, { l, col })
end, {})

vim.api.nvim_create_user_command("UniqLines", function(opts)
  local start, last = 1, vim.fn.line("$")
  if opts.range == 2 then
    start, last = opts.line1, opts.line2
  end
  local removed = text.dedupe_lines(start, last, opts.bang)
  local linecount = last - start + 1
  return notifications.info(("Removed %d duplicates over %d lines"):format(removed, linecount))
end, { desc = "Remove duplicate lines, keeping the first", bang = true, range = true, bar = true })

local function loop(client)
  if client.name == "null-ls" then return end
  local capAsList = {}
  for key, value in pairs(client.server_capabilities) do
    if value and key:find("Provider") then
      local capability = key:gsub("Provider$", "")
      table.insert(capAsList, capability)
    end
  end
  table.sort(capAsList) -- sorts alphabetically

  local msg = ("# %s\n%s"):format(client.name, table.concat(capAsList, "\n"))
  notifications.info(msg, { timeout = 14 * 1000 })
end
vim.api.nvim_create_user_command("LspCapabilities", function()
  local curBuf = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = curBuf })
  vim.tbl_map(loop, clients)
end, {})

vim.api.nvim_create_user_command(
  "OrganizeImports",
  function() return require("utils.organize_imports").organize_imports(0, true) end,
  {}
)
