---@type LazySpec
return {
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    init = function() -- Disable entire built-in ftplugin mappings to avoid conflicts.
      vim.g.no_plugin_maps = true
    end,
  },
  { -- syntax highlighting.
    "arborist-ts/arborist.nvim",
    lazy = false,
    cmd = { "Arborist", "ArboristInstall", "ArboristUpdate", "ArboristClean" },
    opts = {
      ensure_installed = require("utils").flatten({
        { "bash", "c", "diff", "dockerfile", "git_config", "html", "java", "javascript", "jsdoc", "json" },
        { "json5", "lua", "luadoc", "luap", "make", "markdown", "markdown_inline", "python", "query" },
        { "regex", "styled", "toml", "tsx", "typescript", "vim", "vimdoc", "xml", "yaml" },
      }),
    },
  },

  { -- Automatically add closing tags for HTML and JSX
    "windwp/nvim-ts-autotag",
    event = "LazyFile",
    opts = {},
  },
}
