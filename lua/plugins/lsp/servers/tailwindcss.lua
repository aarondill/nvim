return {
  "neovim/nvim-lspconfig",
  optional = true,
  opts = {
    servers = {
      tailwindcss = { ---@type lspconfig.options.tailwindcss
        mason = false,
        settings = { ---@type lspconfig.settings.tailwindcss|{}
          scss = { validate = false },
          editor = {
            quickSuggestions = { strings = true },
            autoClosingQuotes = "always",
          },
          tailwindCSS = { ---@type _.lspconfig.settings.tailwindcss.TailwindCSS|{}
            experimental = { ---@type _.lspconfig.settings.tailwindcss.Experimental|{}
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
      },
    },
  },
}
