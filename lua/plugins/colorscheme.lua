local is_tty = require("utils.is_tty")
local notifications = require("utils.notifications")
---@param colorscheme fun()|string|(fun()|string)[]
local function set_colorscheme(colorscheme)
  if type(colorscheme) ~= "table" then colorscheme = { colorscheme } end
  for _, c in ipairs(colorscheme) do
    if type(c) == "function" then
      local ok = pcall(c)
      if ok then return true end
    end
    local ok = pcall(vim.cmd.colorscheme, c)
    if ok then return true end
  end
  return false
end

vim.api.nvim_create_autocmd("User", {
  group = group,
  pattern = "VeryLazy",
  once = true,
  callback = function()
    local colorscheme = not is_tty() and { require("tokyonight").load } or { "wildcharm", "pablo" }
    local ok = set_colorscheme(colorscheme)
    if not ok then
      notifications.error("Could not load your colorscheme")
      vim.cmd.colorscheme("habamax")
    end
  end,
})

---@type LazySpec
return {
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = {
      transparent = true, -- Enable this to disable setting the background color
      dim_inactive = true, -- dims inactive windows
      style = "night", -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },
  -- Set to transparent (to avoid error notification)
  { "rcarriga/nvim-notify", optional = true, opts = { background_colour = "#000000" } },
}
