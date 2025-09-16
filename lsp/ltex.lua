local notifications = require("utils.notifications")
local chachedir = vim.fn.stdpath("cache")
local root_safe = require("utils.root_safe")
local configdir = vim.fn.stdpath("config")
assert(type(chachedir) == "string", "stdpath cache dir is not a string")
assert(type(configdir) == "string", "stdpath config dir is not a string")

local ngrams_dir = vim.fs.joinpath(chachedir, "ngrams")

local thisdir = debug.getinfo(1, "S").source:match("@(.*)/")
assert(thisdir, "Could not find thisdir")

local function download_ltex_ngram()
  if not root_safe then return end -- Don't download into later inaccessible home
  ---Map of directories to urls
  local urls = {
    en = [[https://languagetool.org/download/ngram-data/ngrams-en-20150817.zip]],
    es = [[https://languagetool.org/download/ngram-data/ngrams-es-20150915.zip]],
  }
  for lang, url in pairs(urls) do
    --- Already downloaded
    if vim.loop.fs_stat(vim.fs.joinpath(ngrams_dir, lang)) then return end

    vim.fn.mkdir(chachedir, "p")
    vim.fn.mkdir(ngrams_dir, "p")

    vim.system({ vim.fs.joinpath(thisdir, "ltex-dl.sh"), url, ngrams_dir }, {
      cwd = chachedir,
      detach = true,
      timeout = 30 * 60 * 1000, -- minutes
    }, function(st)
      if st.code == 75 then return end -- already running
      if st.code ~= 0 or st.signal ~= 0 then
        return notifications.error("ltex download failed: " .. (st.stderr or ""))
      end
      return notifications.info("ltex download complete")
    end)
  end
end
local dictionary_en_us
do
  local ok, lines = pcall(vim.fn.readfile, vim.fs.joinpath(configdir, "spell", "en.utf-8.add"))
  if ok then dictionary_en_us = lines end
end

---- Example .lazy.lua for spanish workspace ----
if false then
  --- This file loads before config/options.lua, so we need to wait to do this
  vim.api.nvim_create_autocmd("User", {
    ---Neovim doesn´t come with spanish dictionaries, so just disable spellchecking
    callback = function() vim.o.spell = false end,
    pattern = "VeryLazy",
    once = true,
  })
  --- Override the ltex language to spanish (Needs ngrams downloaded!)
  vim.lsp.config("ltex", { ---@type vim.lsp.Config
    settings = {
      before_init = function(params, config)
        local d = config.settings.ltex.languageModel
        if not d or not vim.loop.fs_stat(vim.fs.joinpath(d, "es")) then
          vim.notify("Warning: Spanish language model not found", vim.log.levels.WARN)
        end
      end,
      ltex = { language = "es" },
    },
  })
end
---- End example .lazy.lua for spanish workspace ----

download_ltex_ngram() -- On startup, download the language model

return { ---@type vim.lsp.Config
  filetypes = { "latex", "tex", "bib", "markdown", "gitcommit", "text" }, -- No more HTML
  settings = {
    ltex = {
      enabled = true,
      language = "en-US",
      languageModel = ngrams_dir,
      dictionary = { ["en-US"] = dictionary_en_us },
    },
  },
}
