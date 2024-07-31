local names = { "reminder", "todo" }
local extensions = { ".txt", ".md", "" }

for _, name in ipairs(names) do
  for _, ext in ipairs(extensions) do
    vim.filetype.add({
      pattern = { ["%.?" .. name .. ext] = "markdown" },
    })
  end
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
    [".tmpl"] = function(path) return vim.fs.basename(path):match(".+%.(.+).tmpl$") end,
  },
})
