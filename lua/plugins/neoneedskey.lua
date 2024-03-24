---@type LazySpec
return {
  "zSnails/NeoNeedsKey",
  opts = { timeout = 0 },
  cmd = { "ActivateNeovim", "DeactivateNeovim" },
  event = { "VeryLazy" },
}
