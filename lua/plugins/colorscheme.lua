local create_autocmd = require("utils.create_autocmd")
local is_tty = require("utils.is_tty")
local notifications = require("utils.notifications")
local function call_or_colorscheme(colorscheme)
  if type(colorscheme) == "function" then return colorscheme() end
  return vim.cmd.colorscheme(colorscheme)
end
---@param colorscheme fun()|string|(fun()|string)[]
local function set_colorscheme(colorscheme)
  if type(colorscheme) ~= "table" then colorscheme = { colorscheme } end
  for _, c in ipairs(colorscheme) do
    local ok = pcall(call_or_colorscheme, c)
    if ok then return true end
  end
  return false
end

--I don't like background colors. Don't set it.
create_autocmd("ColorScheme", function()
  return vim
    .iter({
      { "Normal", "NormalNC", "SignColumn", "FoldColumn" },
      {
        { "NotifyDEBUGBody", "NotifyDEBUGBorder", "NotifyERRORBody", "NotifyERRORBorder", "NotifyINFOBody" },
        { "NotifyINFOBorder", "NotifyTRACEBody", "NotifyTRACEBorder", "NotifyWARNBody", "NotifyWARNBorder" },
      },
    })
    :flatten(2)
    :each(function(hl) vim.cmd.hi(hl, "guibg=NONE", "ctermbg=NONE") end)
end, { desc = "Remove background colors from colorscheme" })

local function load_colorscheme()
  ---@type fun()|string|(fun()|string)[]
  local colorscheme = { "tokyonight" }
  if is_tty() then colorscheme = { "wildcharm", "pablo" } end
  local ok, err = set_colorscheme(colorscheme)
  if not ok then
    notifications.error("Could not load your colorscheme: " .. err)
    set_colorscheme("habamax")
  end
end
---Wrapped to allow lazy.nvim to setup lazy loading
create_autocmd("User", vim.schedule_wrap(load_colorscheme), { pattern = "LazyDone", once = true })

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
