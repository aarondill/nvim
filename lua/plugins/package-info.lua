local create_autocmd = require("utils.create_autocmd")
local is_tty = require("utils.is_tty")
local function lazy_method(m)
  return function() return require("package-info")[m]() end
end
---@type LazySpec
return {
  {
    "vuki656/package-info.nvim",
    opts = {
      icons = { enable = not is_tty() },
      hide_up_to_date = true, -- It hides up to date versions when displaying virtual text
      -- Can be `npm`, `yarn`, or `pnpm`. Used for `delete`, `install` etc...
      -- The plugin will try to auto-detect the package manager based on
      -- `yarn.lock` or `package-lock.json`. If none are found it will use the
      -- provided one, if nothing is provided it will use `yarn`
      package_manager = "pnpm",
    },
    dependencies = { "MunifTanjim/nui.nvim", "nvim-telescope/telescope.nvim" },
    event = "BufEnter package.json",
    keys = {
      { "<leader>ns", lazy_method("show"), desc = "Show package versions" }, -- Show dependency versions
      { "<leader>nd", lazy_method("delete"), desc = "Delete dependency" }, -- Delete dependency on the line
      { "<leader>nu", lazy_method("update"), desc = "Update dependency" }, -- Update dependency on the line
      { "<leader>np", lazy_method("change_version"), desc = "Change dependency version" }, -- Install a different dependency version
      { "<leader>ni", lazy_method("install"), desc = "Install dependency" }, -- Install a new dependency
    },
    config = function(_, opts)
      require("package-info").setup(opts)
      require("telescope").load_extension("package_info")

      -- Setup colors correctly
      local augroup = vim.api.nvim_create_augroup("package_info_augroup", { clear = true })
      create_autocmd("ColorScheme", "highlight PackageInfoOutdatedVersion guifg=red guibg=NONE", { group = augroup })
      create_autocmd("ColorScheme", "highlight PackageInfoUpToDateVersion guifg=green guibg=NONE", { group = augroup })
      vim.api.nvim_exec_autocmds("ColorScheme", { group = augroup })
    end,
  },
}
