local M = {}
---@class TabProvider
---@field active? boolean|fun():boolean
---Return a value for the expr mapping
---@field run fun(): string?

---@type TabProvider[]
M.providers = {}

local map = require("utils.map")
--- supermaven
M.providers[#M.providers + 1] = {
  active = function()
    return package.loaded["supermaven-nvim"] and require("supermaven-nvim.completion_preview").has_suggestion()
  end,
  run = vim.schedule_wrap(function() return require("supermaven-nvim.completion_preview").on_accept_suggestion() end),
}

--- Tabnine
M.providers[#M.providers + 1] = {
  active = function() return package.loaded["tabnine"] and require("tabnine.keymaps").has_suggestion() end,
  run = function() return require("tabnine.keymaps").accept_suggestion() end,
}

--- LuaSnip
M.providers[#M.providers + 1] = {
  active = function() return package.loaded["luasnip"] and require("luasnip").jumpable(1) end,
  run = function() return require("luasnip").jump(1) end,
}

map("i", "<tab>", function()
  for _, provider in ipairs(M.providers) do
    if provider.active() then return provider.run() end
  end
  return "<tab>"
end, "Tab completion in insert mode", { expr = true })

return M
