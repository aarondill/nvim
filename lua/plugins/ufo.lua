-- handle folds
-- Modified from: https://github.com/sho-87/dotfiles/blob/09872d0905883a1be33d5bb3164076e730d44466/nvim/lua/plugins/modules/ufo.lua
local consts = require("consts")

local handler = function(virtText, lnum, endLnum, width, truncate)
  local newVirtText = {}
  local suffix = (" %d lines"):format(endLnum - lnum)
  local sufWidth = vim.fn.strdisplaywidth(suffix)
  local targetWidth = width - sufWidth
  local curWidth = 0
  for _, chunk in ipairs(virtText) do
    local chunkText = chunk[1]
    local chunkWidth = vim.fn.strdisplaywidth(chunkText)
    if targetWidth > curWidth + chunkWidth then
      table.insert(newVirtText, chunk)
    else
      chunkText = truncate(chunkText, targetWidth - curWidth)
      local hlGroup = chunk[2]
      table.insert(newVirtText, { chunkText, hlGroup })
      chunkWidth = vim.fn.strdisplaywidth(chunkText)
      -- str width returned from truncate() may less than 2nd argument, need padding
      if curWidth + chunkWidth < targetWidth then suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth) end
      break
    end
    curWidth = curWidth + chunkWidth
  end
  table.insert(newVirtText, { suffix, "MoreMsg" })
  return newVirtText
end

---@type LazySpec
return {
  "kevinhwang91/nvim-ufo",
  dependencies = "kevinhwang91/promise-async",
  event = { "BufReadPost", "BufNewFile", "BufWritePre" },
  main = "ufo",
  config = function(plugin, opts)
    vim.o.fillchars = [[eob: ,fold: ,foldopen:▼,foldsep: ,foldclose:>]]
    vim.o.foldcolumn = "1"
    return require(plugin.main).setup(opts)
  end,
  opts = {
    fold_virt_text_handler = handler,
    provider_selector = function(_, filetype)
      return vim.tbl_contains(consts.ignored_filetypes, filetype) and { "" } or { "treesitter", "indent" }
    end,
    preview = {
      win_config = {
        border = { "", "─", "", "", "", "─", "", "" },
        winhighlight = "Normal:Folded",
        winblend = 5,
      },
      mappings = {
        scrollU = "<C-u>",
        scrollD = "<C-d>",
      },
    },
  },
}
