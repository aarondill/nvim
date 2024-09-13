local notifications = require("utils.notifications")
local chachedir = vim.fn.stdpath("cache")
assert(type(chachedir) == "string", "stdpath cache dir is not a string")
local ngrams_dir = vim.fs.joinpath(chachedir, "ngrams")

local thisdir = debug.getinfo(1, "S").source:match("@(.*)/")
assert(thisdir, "Could not find thisdir")

local function download_ltex_ngram()
  local url = [[https://languagetool.org/download/ngram-data/ngrams-en-20150817.zip]]
  --- Already downloaded
  if vim.loop.fs_stat(vim.fs.joinpath(ngrams_dir, "en")) then return end

  vim.fn.mkdir(chachedir, "p")
  vim.fn.mkdir(ngrams_dir, "p")

  vim.system({ vim.fs.joinpath(thisdir, "ltex-dl.sh"), url, ngrams_dir }, {
    cwd = chachedir,
    detach = true,
    timeout = 30 * 60 * 1000, -- minutes
  }, function(st)
    if st.code == 75 then return end -- already running
    if st.code ~= 0 or st.signal ~= 0 then return notifications.error("ltex download failed: " .. (st.stderr or "")) end
    return notifications.info("ltex download complete")
  end)
end

---@type LazySpec
return {
  "neovim/nvim-lspconfig",
  optional = true,
  init = download_ltex_ngram,
  ---@type PluginLspOpts
  opts = {
    servers = {
      ltex = {
        mason = true, -- auto install
        settings = {
          ltex = {
            enabled = true,
            checkFrequency = 1000,
            language = "en-US",
            languageModel = ngrams_dir,
          },
        },
      },
    },
  },
}
