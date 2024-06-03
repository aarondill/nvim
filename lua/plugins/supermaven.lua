local ignored = {}
for _, ft in ipairs(require("consts").ignored_filetypes) do
  ignored[ft] = true
end

---@type LazySpec
return {
  {
    "supermaven-inc/supermaven-nvim",
    main = "supermaven-nvim",
    event = { "LazyFile" },
    cmd = {
      "SupermavenUseFree",
      "SupermavenLogout",
      "SupermavenUsePro",
    },
    opts = {
      ignore_filetypes = ignored,
      disable_keymaps = true,
    },
  },
  { "tabnine-nvim", optional = true, enabled = false },
}
