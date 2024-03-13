require("utils.pr_merged").on_lazy("Djancyp/better-comments.nvim", { 19, 18 })
---@type LazySpec
return {
  "aarondill/better-comments.nvim",
  opts = {
    tags = {
      { match = "!", fg = "#f44747", bg = "", bold = true, virtual_text = "" },
    },
  },
}
