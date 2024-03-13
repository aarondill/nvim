---@type LazySpec
return {
  "alker0/chezmoi.vim",
  lazy = false,
  init = function()
    vim.g["chezmoi#use_tmp_buffer"] = true
    vim.g["chezmoi#use_external"] = true
  end,
}
