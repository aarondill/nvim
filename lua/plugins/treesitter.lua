---@generic T
---@param t T[]
---@return T[]
local function distinct(t)
  local added = {} ---@type table<string, boolean>
  for _, v in ipairs(t) do
    added[v] = true
  end
  return vim.tbl_keys(added)
end
---@type LazySpec
return {
  { -- syntax highlighting.
    "nvim-treesitter/nvim-treesitter",
    version = false, -- last release is way too old and doesn't work on Windows
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile", "BufWritePre", "VeryLazy" },
    init = function(plugin)
      -- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
      -- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
      -- no longer trigger the **nvim-treesitter** module to be loaded in time.
      -- Luckily, the only things that those plugins need are the custom queries, which we make available
      -- during startup.
      require("lazy.core.loader").add_to_rtp(plugin)
      require("nvim-treesitter.query_predicates")
    end,
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    keys = {
      { "<c-space>", desc = "Increment selection" },
      { "<bs>", desc = "Decrement selection", mode = "x" },
    },
    ---@diagnostic disable-next-line: missing-fields
    opts = { ---@type TSConfig
      highlight = { enable = true },
      indent = { enable = true },
      ensure_installed = vim.tbl_flatten({
        { "bash", "c", "diff", "html", "javascript", "jsdoc", "json", "jsonc" },
        { "lua", "luadoc", "luap", "markdown", "markdown_inline", "python", "query", "regex", "toml" },
        { "tsx", "typescript", "vim", "vimdoc", "xml", "yaml" },
      }),
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
      textobjects = {
        move = {
          enable = true,
          goto_next_start = { ["]f"] = "@function.outer" },
          goto_next_end = { ["]F"] = "@function.outer" },
          goto_previous_start = { ["[f"] = "@function.outer" },
          goto_previous_end = { ["[F"] = "@function.outer" },
        },
      },
    },
    config = function(_, opts) ---@param opts TSConfig
      local ensure_installed = opts.ensure_installed
      if type(ensure_installed) == "table" then opts.ensure_installed = distinct(ensure_installed) end
      return require("nvim-treesitter.configs").setup(opts)
    end,
  },

  { -- Automatically add closing tags for HTML and JSX
    "windwp/nvim-ts-autotag",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    opts = {},
  },
}
