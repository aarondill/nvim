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
    -- Locked to fixed commit: see supermaven-inc/supermaven-nvim#74
    commit = "df3ecf7",
    cmd = {
      "SupermavenUseFree",
      "SupermavenLogout",
      "SupermavenUsePro",
      "SupermavenStart",
      "SupermavenStop",
      "SupermavenRestart",
      "SupermavenStatus",
    },
    opts = {
      ignore_filetypes = ignored,
      disable_keymaps = true,
    },
  },
  { "tabnine-nvim", optional = true, enabled = false },
}
