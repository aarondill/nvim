-- copied from cmp-under, but I don't think I need the plugin for this.
-- I might add some more of my own.
local function under_cmp(entry1, entry2)
  local _, entry1_under = entry1.completion_item.label:find("^_+")
  local _, entry2_under = entry2.completion_item.label:find("^_+")
  entry1_under = entry1_under or 0
  entry2_under = entry2_under or 0
  if entry1_under > entry2_under then
    return false
  elseif entry1_under < entry2_under then
    return true
  end
end
---@param entry1 cmp.Entry
---@param entry2 cmp.Entry
local function snippets_down(entry1, entry2)
  local types = require("cmp.types")
  local kind1, kind2 = entry1:get_kind(), entry2:get_kind()
  local Snippet = types.lsp.CompletionItemKind.Snippet
  if kind1 == Snippet then
    -- Only return if 2 is not a snippet
    if kind2 ~= Snippet then return false end
  elseif kind2 == Snippet then
    return true
  else -- Neither is a snippet, ignore it
    return
  end
  -- Both are snippets, discourage nvim_lsp snippets
  if entry1.source.name == "nvim_lsp" then return false end
  if entry2.source.name == "nvim_lsp" then return true end
end

---@type LazySpec
return {
  -- auto completion
  {
    "hrsh7th/nvim-cmp",
    version = false, -- last release is way too old
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
    opts = function()
      local cmp = require("cmp")
      local compare = cmp.config.compare
      return { ---@type cmp.ConfigSchema
        -- Change border of documentation hover window, See https://github.com/neovim/neovim/pull/13998.
        window = { completion = { border = "rounded" }, documentation = { border = "rounded" } },
        completion = { completeopt = "menu,menuone,noinsert" },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = false }), -- Accept without explicit selection
          ["<S-CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
          ["<C-CR>"] = function(fallback)
            cmp.abort()
            fallback()
          end,
        }),
        sources = cmp.config.sources({ { name = "nvim_lsp" }, { name = "path" } }, { { name = "buffer" } }),
        formatting = { ---@type cmp.FormattingConfig|{}
          format = function(_, item)
            local icons = require("config.icons").lazyvim.icons.kinds
            if icons[item.kind] then item.kind = icons[item.kind] .. item.kind end
            return item
          end,
        },
        performance = { ---@type cmp.PerformanceConfig|{}
          trigger_debounce_time = 500,
          throttle = 550,
          fetching_timeout = 80,
        },
        experimental = { ghost_text = false }, -- Don't show the ghost text
        sorting = {
          priority_weight = 2,
          comparators = {
            compare.offset,
            compare.exact,
            snippets_down,
            compare.score,
            compare.recently_used,
            compare.locality,
            under_cmp,
            compare.scopes, -- prioritize values in scope order
            compare.kind, -- superseded by lsp_first -- just used for lowering text
            compare.sort_text,
            compare.length,
            compare.order,
          },
        },
      }
    end,
    ---@param opts cmp.ConfigSchema
    config = function(_, opts)
      for _, source in ipairs(opts.sources) do
        source.group_index = source.group_index or 1
      end
      require("cmp").setup(opts)
    end,
  },
}
