local is_tty = require("utils.is_tty")
---@type LazySpec
return {
  {
    "danielfalk/smart-open.nvim",
    keys = {
      {
        "<leader><leader>",
        function() require("telescope").extensions.smart_open.smart_open() end,
      },
    },
    opts = {
      match_algorithm = "fzf",
      disable_devicons = is_tty(),
    },
    config = function(_, opts)
      require("smart-open").setup(opts)
      require("telescope").load_extension("smart_open")
    end,
    dependencies = {
      "kkharji/sqlite.lua",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-telescope/telescope.nvim",
    },
  },
}
