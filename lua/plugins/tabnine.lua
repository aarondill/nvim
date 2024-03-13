local root_safe = require("utils.root_safe")
local use_tabnine = true
if not root_safe then
  vim.notify("Disabling tabnine because the $HOME variable != user's home directory!", vim.log.levels.WARN)
  use_tabnine = false
elseif vim.loop.cwd() == vim.loop.os_homedir() and vim.loop.os_uname().release:find("-arch%d*-") then
  vim.notify("Disabling tabnine because cwd is $HOME! (on an Arch Linux machine)", vim.log.levels.WARN)
  use_tabnine = false -- NOTE: tabnine doesn't seem to have this problem on Ubuntu
end

local use_upstream = false

---@type LazySpec
return {
  -- Tabnine setup
  {
    ("%s/tabnine-nvim"):format(use_upstream and "codota" or "aarondill"),
    dev = false,

    cond = use_tabnine,
    branch = use_upstream and "master" or "all_together_now",
    build = "./dl_binaries.sh",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    cmd = {
      "TabnineChat",
      "TabnineChatClear",
      "TabnineChatClose",
      "TabnineChatNew",
      "TabnineDisable",
      "TabnineEnable",
      "TabnineHub",
      "TabnineHubUrl",
      "TabnineLogin",
      "TabnineLogout",
      "TabnineStatus",
      "TabnineToggle",
    },
    main = "tabnine",
    opts = {
      disable_auto_comment = false, -- I already handle this. Default: true
      accept_keymap = "<F22>", -- Default: "<Tab>" -- This is *effectively* disabled. there's no true way to disable it.
      dismiss_keymap = "<C-]>", -- Default: "<C-]>"
      debounce_ms = 500, -- Faster pls. Default: 800
      suggestion_color = { gui = "#808080", cterm = 244 }, -- Default: { gui = "#808080", cterm = 244 }
      exclude_filetypes = require("consts").ignored_filetypes, -- Default: { "TelescopePrompt" }
      codelens_enabled = false,
    },
  },
  -- Lualine show Tabnine status
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts = opts or {}
      opts.sections = opts.sections or {}
      opts.sections.lualine_b = opts.sections.lualine_b or {}
      table.insert(opts.sections.lualine_b, "tabnine")
      return opts
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp = require("cmp")
      return vim.tbl_deep_extend("force", opts or {}, {
        mapping = {
          -- Accept without explicit selection
          ["<TAB>"] = cmp.mapping(function(fallback)
            local tabnine_keymaps = require("tabnine.keymaps")
            if tabnine_keymaps.accept_suggestion and tabnine_keymaps.accept_suggestion() then
              return
            elseif cmp.visible() then
              cmp.confirm({ select = false })
            else
              -- Fallback is not mapped correctly. Just hard code a tab character
              vim.api.nvim_feedkeys("\t", "n", false)
              -- fallback()
            end
          end, { "i" }),
        },
      })
    end,
  },
}
