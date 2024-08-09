local extensions = { ".txt", ".md", "" }
local names = { "reminder", "todo" } -- both capitals and lowercase will be added
local home = os.getenv("HOME")

vim
  .iter(names)
  :map(function(name) ---@param name string
    return { name:lower(), name:gsub("^%l", string.upper), name:upper() }
  end)
  :flatten(1)
  :map(function(name) return { "." .. name, name } end) -- Add leading dot
  :flatten(1)
  :map(function(name) ---@param name string
    return vim.iter(extensions):map(function(ext) return name .. ext end):totable()
  end)
  :flatten(1)
  :map(function(file) return vim.fs.joinpath(home, file) end)
  :each(function(file) ---@param file string
    return vim.filetype.add({ filename = { [file] = "markdown" } })
  end)

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
