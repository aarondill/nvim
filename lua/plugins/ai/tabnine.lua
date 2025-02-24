local flatten = require("utils.flatten")
local use_upstream = true

---@type LazySpec
return {
  -- Tabnine setup
  ("%s/tabnine-nvim"):format(use_upstream and "codota" or "aarondill"),
  dev = false,
  cond = function()
    local notifications = require("utils.notifications")
    local root_safe = require("utils.root_safe")
    if not root_safe then
      notifications.warn("Disabling tabnine because the $HOME variable != user's home directory!", { once = true })
      return false
    end
    return true
  end,
  branch = use_upstream and "master" or "all_together_now",
  build = "./dl_binaries.sh",
  event = "InsertEnter",
  cmd = flatten(
    { "TabnineChat", "TabnineChatClear", "TabnineChatClose", "TabnineChatNew", "TabnineDisable" },
    { "TabnineEnable", "TabnineHub", "TabnineHubUrl", "TabnineLogin" },
    { "TabnineLogout", "TabnineStatus", "TabnineToggle" }
  ),
  main = "tabnine",
  opts = {
    disable_auto_comment = false, -- I already handle this. Default: true
    accept_keymap = false, -- Default: "<Tab>"
    dismiss_keymap = false, -- Default: "<C-]>"
    debounce_ms = 500, -- Faster pls. Default: 800
    suggestion_color = { gui = "#808080", cterm = 244 },
    exclude_filetypes = require("consts").ignored_filetypes, -- Default: { "TelescopePrompt" }
    codelens_enabled = false,
  },
  -- Note: <tab> is handled in keymaps.lua,
}
