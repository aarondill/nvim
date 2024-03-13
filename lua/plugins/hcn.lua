local hcn
do
  --- HACK: Clear the noice search_count when moving
  local jumping = false -- keep track of if we're jumping to the next match
  local autocmd = nil -- the cached autocmd id. Used to make sure that CursorMoved isn't *always* running
  local function clear_noice()
    if autocmd then return end -- cache it, we only need one autocmd
    if not package.loaded["noice"] then return end -- noice hasn't loaded, we can skip this
    autocmd = vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter", "CmdlineEnter" }, {
      callback = function()
        if jumping then return end -- this was a jump, keep the count
        local m = require("noice.ui.msg").get("msg_show", "search_count")
        require("noice.message.manager").remove(m)
        autocmd = nil
        return true -- remove the autocmd
      end,
    })
  end

  ---Calls key on highlight_current_n and handles jumping
  ---@param key 'n'|'N'
  ---@return fun()
  function hcn(key)
    return function()
      jumping = true
      require("highlight_current_n")[key]()
      vim.schedule(function() jumping = false end)
      clear_noice()
    end
  end
end

return {
  "rktjmp/highlight-current-n.nvim",
  opts = { highlight_group = "IncSearch" },
  init = function()
    vim.opt.hlsearch = false
    local augroup = vim.api.nvim_create_augroup("ClearSearchHL", { clear = true })
    -- only see hlsearch /while/ searching
    vim.api.nvim_create_autocmd({ "CmdlineEnter", "CmdlineLeave" }, {
      pattern = { "/", "\\?" },
      callback = function(ev)
        local val = ev.event == "CmdlineEnter" -- enable on enter, disable on exit
        vim.opt.hlsearch = val
      end,
      group = augroup,
    })
    -- apply n|N highlighting to the first search result
    vim.api.nvim_create_autocmd("CmdlineLeave", {
      pattern = { "/", "\\?" },
      callback = function() require("highlight_current_n")["/,?"]() end,
      group = augroup,
    })
  end,
  keys = { { "n", hcn("n"), mode = "n" }, { "N", hcn("N"), mode = "n" } },
}
