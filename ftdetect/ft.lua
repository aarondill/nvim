local function detect_noext(path, bufnr)
  local root = vim.fn.fnamemodify(path, ":r")
  return vim.filetype.match({ buf = bufnr, filename = root })
end

-- Override .pluto and .tmpl extensions
vim.filetype.add({
  pattern = {
    [".*/etc/default/grub.d/.*%.cfg"] = "sh",
  },
  filename = {
    ["/etc/default/grub"] = "sh",
  },
  extension = {
    [".pluto"] = "lua",
    [".tmpl"] = detect_noext,
  },
})
