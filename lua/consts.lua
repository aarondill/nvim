local M = {
  ---@type string[]
  ignored_filetypes = {
    "",
    "TelescopePrompt",
    "TelescopeResults",
    "Trouble",
    "alpha",
    "dashboard",
    "help",
    "lazy",
    "lazyterm",
    "lspinfo",
    "mason",
    "neo-tree",
    "notify",
    "nvcheatsheet",
    "nvdash",
    "starter",
    "terminal",
    "toggleterm",
    "trouble",
  },
  root_markers = {
    ".root", -- Allow manual define root
    ".config", -- Custom root file for java projects
    "test.sh", -- Custom root file for java projects
    ".git/",
    ".github/",
    "mvnw",
    "gradlew",
    "pom.xml",
    "build.gradle",
    "package.json",
    "lua/",
    "Makefile",
    "Makefile.am",
  },
  close_on_q = {
    "PlenaryTestPopup",
    "help",
    "lspinfo",
    "notify",
    "qf",
    "query",
    "spectre_panel",
    "startuptime",
    "tsplayground",
    "neotest-output",
    "checkhealth",
    "neotest-summary",
    "neotest-output-panel",
    "git", -- used for fugitive
  },
}
return M
