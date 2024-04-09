local map = require("utils.map")
return {
  "gaoDean/autolist.nvim",
  ft = { "markdown", "text", "tex", "plaintex", "norg" },
  config = function()
    require("autolist").setup()

    map("i", "<CR>", "<CR><cmd>AutolistNewBullet<cr>")
    map("n", "o", "o<cmd>AutolistNewBullet<cr>")
    map("n", "O", "O<cmd>AutolistNewBulletBefore<cr>")
    map("n", "<CR>", "<cmd>AutolistToggleCheckbox<cr><CR>")
    -- functions to recalculate list on edit
    for _, k in ipairs({ ">>", "<<", "dd" }) do
      map("n", k, k .. "<cmd>AutolistRecalculate<cr>")
    end
    map("v", "d", "d<cmd>AutolistRecalculate<cr>")
  end,
}
