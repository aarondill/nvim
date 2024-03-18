local notifications = require("utils.notifications")
local root_safe = require("utils.root_safe")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  if not root_safe then
    notifications.warn(("Warning: cloning lazy.nvim into another user's home directory (%s)."):format(lazypath))
  end
  -- bootstrap lazy.nvim
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

local icons = require("config.icons")
require("lazy").setup({
  ui = { icons = icons.lazy_nvim.ui.icons },
  ---@type table -- Force it. The type is wrong.
  dev = {
    -- directory where you store your local plugin projects
    path = "~/code/repos/",
    ---@type string[] plugins that match these patterns will use your local versions instead of being fetched from GitHub
    patterns = {}, -- For example {"folke"}
    fallback = false, -- Fallback to git when local plugin doesn't exist
  },
  git = {
    timeout = 120, -- kill processes that take more than 2 minutes
    url_format = "https://github.com/%s.git",
    filter = true,
  },
  spec = {
    { import = "plugins" }, -- Import /lua/plugins
  },
  defaults = {
    --- Lazy Load by default!
    lazy = true,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  install = {
    -- install missing plugins on startup. This doesn't increase startup time.
    missing = true,
    colorscheme = { "tokyonight", "habamax" },
  },
  checker = { enabled = root_safe }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "netrwPlugin",
        "tohtml",
        "tutor",
      },
    },
  },
})
