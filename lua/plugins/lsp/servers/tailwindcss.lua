vim.lsp.config("tailwindcss", { ---@type vim.lsp.Config
  settings = {
    scss = { validate = false },
    editor = {
      quickSuggestions = { strings = true },
      autoClosingQuotes = "always",
    },
    tailwindCSS = {
      experimental = {
        classRegex = {
          "tw`([^`]*)", -- tw`...`
          'tw="([^"]*)', -- <div tw="..." />
          'tw={"([^"}]*)', -- <div tw={"..."} />
          "tw\\.\\w+`([^`]*)", -- tw.xxx`...`
          "tw\\(.*?\\)`([^`]*)", -- tw(Component)`...`
        },
      },
      includeLanguages = {
        typescript = "javascript",
        typescriptreact = "javascript",
      },
    },
  },
})

return {}
