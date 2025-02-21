if vim.fn.has("nvim-0.10.0") == 0 then
  vim.api.nvim_echo({
    { "This configurations requires Neovim >= 0.10.0\n", "ErrorMsg" },
    { "Aborting configuration. You will be left with Vanilla Neovim.\n", "ErrorMsg" },
    { "Press any key to continue.", "MoreMsg" },
  }, true, {})
  vim.fn.getchar()
  return
end

---Remove . from the package.path. This never does anything good.
package.path = package.path:gsub("^%./%?%.lua;", "")
package.cpath = package.cpath:gsub("^%./%?%.so;", "")

require("future") -- Fowards compatability

--- Wait until after config is loaded before starting notification timer
local _start_notifs_timer ---@type function?
do -- delay notifications till vim.notify was replaced or after 500ms
  local notifs, orig = {}, vim.notify
  local function temp(...) table.insert(notifs, vim.F.pack_len(...)) end
  vim.notify = temp

  local timer, check = vim.uv.new_timer(), vim.uv.new_check()
  assert(timer)
  assert(check)
  local function replay()
    _ = { timer:stop(), timer:close(), check:stop(), check:close() } -- clean up the timer and check
    timer, check = nil, nil
    if vim.notify == temp then vim.notify = orig end -- put back the original notify if needed
    vim.schedule(function()
      for _, notif in ipairs(notifs) do
        vim.notify(vim.F.unpack_len(notif))
      end
      notifs = nil
    end)
  end

  check:start(function()
    if vim.notify ~= temp then replay() end
  end) -- wait till vim.notify has been replaced
  _start_notifs_timer = function()
    if not timer then return end -- If this is called after the check has fired, then we're good
    timer:start(500, 0, replay) -- or if it took more than 500ms, then something went wrong
    _start_notifs_timer = nil -- only run this once/gc
  end
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

---@class nvim_buf_get_keymap.Keymap
---@field abbr 0|1,
---@field buffer 0|1,
---@field desc? string,
---@field expr 0|1,
---@field lhs string,
---@field lhsraw string,
---@field lnum 0|1,
---@field mode? string,
---@field mode_bits integer,
---@field noremap 0|1,
---@field nowait 0|1,
---@field rhs? string,
---@field callback? function,
---@field script 0|1,
---@field scriptversion integer,
---@field sid integer,
---@field silent 0|1,

vim.schedule(function()
  ---@type nvim_buf_get_keymap.Keymap[]
  local keys = vim
    .iter({ vim.api.nvim_buf_get_keymap(0, ""), vim.api.nvim_get_keymap("") })
    :flatten(1)
    :filter(function(k) ---@param k nvim_buf_get_keymap.Keymap
      return k.lhs ~= "" and not k.lhs:find("^<Plug>") -- exclude plug mappings
    end)
    :filter(function(k) ---@param k nvim_buf_get_keymap.Keymap
      local has_rhs = k.rhs ~= nil and (k.rhs ~= "" and k.rhs:upper() ~= "<NOP>") -- exclude empty mappings
      local has_desc = k.desc ~= nil -- exclude empty descriptions
      local has_callback = k.callback ~= nil -- exclude empty callbacks
      if not has_rhs and not has_callback then return false end -- if this mapping doesn't do anything, don't show it
      return has_desc or has_rhs -- Only show it if it has a description or a rhs (callbacks aren't displayable)
    end)
    :totable()
  local i = math.random(1, #keys)
  local k = keys[i]
  local msg = ('%smap "%s"'):format(k.mode or "", k.lhsraw) .. ": " .. (k.desc or k.rhs)
  require("utils.notifications").info(msg, { title = "Keymap", timeout = 5 * 1000 })
end)

vim.schedule(_start_notifs_timer) -- start the timer after we're done with everything
