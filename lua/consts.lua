local M = {
  ---@type table<string, boolean>
  ignored_filetypes = {
    "",
    "TelescopePrompt",
    "TelescopeResults",
    "alpha",
    "dashboard",
    "help",
    "lazy",
    "lspinfo",
    "mason",
    "neo-tree",
    "nvcheatsheet",
    "nvdash",
    "starter",
    "terminal",
  },
  root_markers = {
    ".git",
    ".github",
    "mvnw",
    "gradlew",
    "pom.xml",
    "build.gradle",
    "package.json",
    "lua/",
    "Makefile",
    "Makefile.am",
  },
}
return M
