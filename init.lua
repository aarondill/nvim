require("future") -- Fowards compatability

-- Override .pluto and .tmpl extensions
vim.filetype.add({
  extension = {
    [".pluto"] = "lua",
    [".tmpl"] = function(path) return vim.fs.basename(path):match(".+%.(.+).tmpl$") end,
  },
})

if vim.fn.has("nvim-0.9.0") == 0 then
  vim.api.nvim_echo({
    { "This configurations requires Neovim >= 0.9.0\n", "ErrorMsg" },
    { "Aborting configuration. You will be left with Vanilla Neovim.\n", "ErrorMsg" },
    { "Press any key to continue.", "MoreMsg" },
  }, true, {})
  vim.fn.getchar()
  return
end

do -- delay notifications till vim.notify was replaced or after 500ms
  local notifs, orig = {}, vim.notify
  local function temp(...) table.insert(notifs, vim.F.pack_len(...)) end
  vim.notify = temp

  local timer, check = vim.uv.new_timer(), assert(vim.uv.new_check())
  local function replay()
    timer:stop()
    check:stop()
    if vim.notify == temp then vim.notify = orig end -- put back the original notify if needed
    vim.schedule(function()
      for _, notif in ipairs(notifs) do
        vim.notify(vim.F.unpack_len(notif))
      end
    end)
  end

  check:start(function()
    if vim.notify ~= temp then replay() end
  end) -- wait till vim.notify has been replaced
  timer:start(500, 0, replay) -- or if it took more than 500ms, then something went wrong
end

require("config.options") -- This needs to come first!
require("config.lazy") -- bootstrap lazy.nvim and plugins

-- Require all the files in ./config
require("lazy.core.util").lsmod("config", require)

--- Handle regenerating helptags in new VIMRUNTIMEs
local rt = os.getenv("VIMRUNTIME")
if rt and vim.loop.fs_access(rt, "W") then
  --- Regen the helptags
  vim.cmd.helptags(vim.fs.joinpath(rt, "doc"))
end
