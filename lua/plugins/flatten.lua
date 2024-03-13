---@type LazySpec
return {
  "willothy/flatten.nvim",
  opts = {
    window = {
      open = "alternate", -- open in alternate window
    },
  },
  -- Ensure that it runs first to minimize delay when opening file from terminal
  lazy = false,
  priority = 1000,
}
