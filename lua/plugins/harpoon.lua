---@type HarpoonToggleOptions
local QUICK_MENU_CONFIG = { ui_width_ratio = 0.80 }
---@param name? string
local function toggle_quick_menu(name)
  local harpoon = require("harpoon")
  local list = harpoon:list(name)
  return harpoon.ui:toggle_quick_menu(list, QUICK_MENU_CONFIG)
end
---@param map string map:format(idx)
---@param ... integer idxes
---Note: this must be the last in the table, since it returns a list of maps
local function nav_map(map, ...)
  local ret = {}
  for _, idx in ipairs({ ... }) do
    ret[#ret + 1] = {
      map:format(idx),
      function() require("harpoon"):list():select(idx) end,
      desc = ("Harpoon to %s file"):format(idx),
    }
  end
  return unpack(ret, 1, ret.n or #ret)
end

---@type LazySpec
return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    settings = {
      save_on_toggle = true,
      sync_on_ui_close = true,
    },
  },
  config = function(_, opts)
    local harpoon = require("harpoon")
    local extensions = require("harpoon.extensions")
    harpoon:setup(opts)
    harpoon:extend(extensions.builtins.navigate_with_number()) -- Support navigating with just the number row in the menu
    harpoon:extend({
      ---@param state { list: HarpoonList, item: HarpoonListItem, idx: integer }
      ADD = function(state)
        return vim.notify(("Added %s to harpoon"):format(state.item.value), vim.log.levels.INFO) -- Notify on add
      end,
      NAVIGATE = function() vim.cmd.ls("%") end,
    })
  end,
  keys = {
    {
      "<leader>H",
      function() require("harpoon"):list():append() end,
      desc = "Harpoon file",
    },
    { "<leader>h", toggle_quick_menu, desc = "Harpoon quick menu" },
    {
      "<m-o>",
      function() require("harpoon"):list():next({ ui_nav_wrap = true }) end,
      desc = "Harpoon to next",
    },
    {
      "<m-i>",
      function() require("harpoon"):list():prev({ ui_nav_wrap = true }) end,
      desc = "Harpoon to previous",
    },
    nav_map("<c-%d>", 1, 2, 3, 4, 5, 6, 7, 8, 9),
  },
}
