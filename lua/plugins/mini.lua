-- register all text objects with which-key
-- Copied from LazyVim (https://github.com/LazyVim/LazyVim/blob/d01a58ef904b9e11378e5c175f3389964c69169d/lua/lazyvim/util/mini.lua#L63)
local function ai_whichkey()
  if not pcall(require, "which-key") then return end
  local defaults = {
    { " ", desc = "whitespace" },
    { '"', desc = '" string' },
    { "`", desc = "` string" },
    { "'", desc = "' string" },
    { "(", desc = "() block" },
    { ")", desc = "() block with ws" },
    { "<", desc = "<> block" },
    { ">", desc = "<> block with ws" },
    { "?", desc = "user prompt" },
    { "[", desc = "[] block" },
    { "]", desc = "[] block with ws" },
    { "_", desc = "underscore" },
    { "a", desc = "argument" },
    { "b", desc = ")]} block" },
    { "f", desc = "function call" },
    { "q", desc = "quote `\"'" },
    { "{", desc = "{} block" },
    { "}", desc = "{} with ws" },
  }
  local objects = vim.list_extend({
    { "i", desc = "indent" }, -- Technically via mini.indentscope
    { "c", desc = "class" },
    { "U", desc = "use/call without dot" },
    { "d", desc = "digit(s)" },
    { "e", desc = "CamelCase / snake_case" },
    { "g", desc = "entire file" },
    { "o", desc = "block, conditional, loop" },
    { "t", desc = "tag" },
    { "u", desc = "use/call" },
  }, defaults)

  local ret = { mode = { "o", "x" } }
  for prefix, name in pairs({ i = "inside", a = "around", il = "last", ["in"] = "next", al = "last", an = "next" }) do
    ret[#ret + 1] = { prefix, group = name }
    for _, obj in ipairs(objects) do
      local desc = obj.desc
      if prefix:sub(1, 1) == "i" then desc = desc:gsub(" with ws", "") end
      ret[#ret + 1] = { prefix .. obj[1], desc = obj.desc }
    end
  end
  return require("which-key").add(ret, { notify = false })
end

---@type LazySpec
return {
  -- Fast and feature-rich surround actions. For text that includes
  -- surrounding characters like brackets or quotes, this allows you
  -- to select the text inside, change or modify the surrounding characters,
  -- and more.
  {
    "echasnovski/mini.surround",
    keys = function(_, keys) ---@param keys LazyKeysSpec[]
      -- Populate the keys based on the user's options
      local plugin = require("lazy.core.config").spec.plugins["mini.surround"]
      local opts = require("lazy.core.plugin").values(plugin, "opts", false)
      local mappings = {
        { opts.mappings.add, desc = "Add surrounding", mode = { "n", "v" } },
        { opts.mappings.delete, desc = "Delete surrounding" },
        { opts.mappings.find, desc = "Find right surrounding" },
        { opts.mappings.find_left, desc = "Find left surrounding" },
        { opts.mappings.highlight, desc = "Highlight surrounding" },
        { opts.mappings.replace, desc = "Replace surrounding" },
        { opts.mappings.update_n_lines, desc = "Update `MiniSurround.config.n_lines`" },
      }
      -- last two don't work until loaded
      local surround = { ["("] = ")", ["{"] = "}", ["'"] = "'", ['"'] = '"', ["["] = "]" }
      for k, v in pairs(surround) do
        local cmd = ([[:<C-u>lua MiniSurround.add('visual')<Cr>]] .. v)
        mappings[#mappings + 1] = { k, cmd, desc = "Surround selection with " .. v, mode = "x" }
      end

      return vim.list_extend(vim.tbl_filter(function(m) return m[1] and #m[1] > 0 end, mappings), keys)
    end,
    opts = {
      n_lines = 50, -- Number of lines within which surrounding is searched
      -- Whether to respect selection type:
      -- - Place surroundings on separate lines in linewise mode.
      -- - Place surroundings on each line in blockwise mode.
      respect_selection_type = false,
      mappings = {
        add = "gza", -- Add surrounding in Normal and Visual modes
        delete = "gzd", -- Delete surrounding
        find = "gzf", -- Find surrounding (to the right)
        find_left = "gzF", -- Find surrounding (to the left)
        highlight = "gzh", -- Highlight surrounding
        replace = "gzr", -- Replace surrounding
        update_n_lines = "gzn", -- Update `n_lines`
      },
    },
  },
  ---- auto pairs
  -- {
  --   "echasnovski/mini.pairs",
  --   event = "VeryLazy",
  --   opts = {},
  --   keys = {
  --     {
  --       "<leader>up",
  --       function()
  --         vim.g.minipairs_disable = not vim.g.minipairs_disable
  --         local msg = vim.g.minipairs_disable and "Disabled %s" or "Enabled %s"
  --         return notifications.info(msg:format("auto pairs"), { title = "Option" })
  --       end,
  --       desc = "Toggle auto pairs",
  --     },
  --   },
  -- },
  -- comments
  {
    "echasnovski/mini.comment",
    dependencies = {
      { "JoosepAlviste/nvim-ts-context-commentstring", opts = { enable_autocmd = false }, lazy = true },
    },
    event = "VeryLazy",
    opts = {
      options = {
        custom_commentstring = function()
          return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring
        end,
      },
    },
  },
  {
    "echasnovski/mini.extra",
    optional = true, -- Don't load unless it's being used as dependency
    config = true, -- call setup. Strickly speaking, this is not necessary; but the docs say to do it
  },
  -- Better text-objects
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    dependencies = "echasnovski/mini.extra",
    opts = function()
      local ai = require("mini.ai")
      local gen_ai_spec = require("mini.extra").gen_ai_spec
      return {
        n_lines = 500,
        custom_textobjects = {
          g = gen_ai_spec.buffer(), -- g like gg or G
          L = gen_ai_spec.line(), -- can't use 'l' because of conflict with 'a/i last X'
          d = gen_ai_spec.number(), -- d for digit

          o = ai.gen_spec.treesitter({ -- code block "outer"
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- function
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }), -- class
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
          e = { -- Word with case
            { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
            "^().*()$",
          },
          u = ai.gen_spec.function_call(), -- u for "Usage"
          U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
        },
      }
    end,
    config = function(_, opts)
      require("mini.ai").setup(opts)
      return ai_whichkey()
    end,
  },
}
