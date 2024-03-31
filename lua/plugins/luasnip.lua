local config = vim.fn.stdpath("config")
assert(type(config) == "string")
local snippet_dir = vim.fs.joinpath(config, "snippets")

---@type LazySpec
return {
  {
    "L3MON4D3/LuaSnip",
    build = (not jit.os:find("Windows"))
        and "echo 'NOTE: jsregexp is optional, so not a big deal if it fails to build'; make install_jsregexp"
      or nil,
    dependencies = { "rafamadriz/friendly-snippets", "nvim-cmp" },
    opts = { history = true, delete_check_events = "TextChanged" },
    -- Note: <tab> in insert is handled in keymaps.lua
    keys = {
      { "<tab>", function() require("luasnip").jump(1) end, mode = "s" },
      { "<s-tab>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } },
    },
    config = function(opts)
      require("luasnip").setup(opts)
      require("luasnip.loaders.from_vscode").lazy_load({ paths = snippet_dir })
    end,
  },
  {
    "rafamadriz/friendly-snippets",
    config = function(self) return require("luasnip.loaders.from_vscode").lazy_load({ paths = self._.dir }) end,
  },
  {
    "nvim-cmp",
    dependencies = { "saadparwaiz1/cmp_luasnip" },
    opts = function(_, opts)
      opts.snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end }
      table.insert(opts.sources, { name = "luasnip" })
    end,
  },
  {
    "chrisgrieser/nvim-scissors",
    dependencies = "nvim-telescope/telescope.nvim",
    opts = { ---@type pluginConfig | {}
      snippetDir = snippet_dir,
      jsonFormatter = vim.fn.executable("jq") == 1 and "jq" or "none",
    },
  },
}
