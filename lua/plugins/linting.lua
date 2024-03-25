local notifications = require("utils.notifications")
local function debounce(ms, fn)
  fn = vim.schedule_wrap(fn)
  local timer -- don't initialize the timer until first call
  return function(...)
    timer = timer or vim.loop.new_timer()
    local argv = vim.F.pack_len(...)
    timer:start(ms, 0, function()
      timer:stop()
      return fn(vim.F.unpack_len(argv))
    end)
  end
end

---@class Linter :lint.Linter
---@field condition? fun(ctx: {filename: string, dirname: string}): boolean?

---@type LazySpec
return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPost", "BufNewFile", "BufWritePre" },
  ---@class LintOptions
  opts = {
    -- Event to trigger linters
    events = { "BufWritePost", "BufReadPost", "InsertLeave" },
    -- Use the "*" filetype to run linters on all filetypes.
    -- Use the "_" filetype to run linters on filetypes that don't have other linters configured.
    ---@type table<string, string[]>
    linters_by_ft = {
      fish = { "fish" },
    },
    -- extension to easily override linter options or add custom linters.
    ---@type table<string,Linter|fun():Linter>
    linters = {
      -- -- Example of using selene only when a selene.toml file is present
      -- selene = {
      --   -- `condition` is another extension that allows you to dynamically enable/disable linters based on the context.
      --   condition = function(ctx)
      --     return vim.fs.find({ "selene.toml" }, { path = ctx.filename, upward = true })[1]
      --   end,
      -- },
    },
  },
  config = function(_, opts)
    local lint = require("lint")
    for name, linter in pairs(opts.linters) do
      local dest = lint.linters[name]
      if type(linter) == "table" and type(dest) == "table" then
        lint.linters[name] = vim.tbl_deep_extend("force", dest, linter)
      else
        lint.linters[name] = linter
      end
    end
    lint.linters_by_ft = opts.linters_by_ft

    local function dolint()
      -- Use nvim-lint's logic first:
      -- * checks if linters exist for the full filetype first
      -- * otherwise will split filetype by "." and add all those linters
      -- * this differs from conform.nvim which only uses the first filetype that has a formatter
      local names = lint._resolve_linter_by_ft(vim.bo.filetype)

      -- Add fallback linters.
      if #names == 0 then vim.list_extend(names, lint.linters_by_ft["_"] or {}) end

      -- Add global linters.
      vim.list_extend(names, lint.linters_by_ft["*"] or {})

      -- Filter out linters that don't exist or don't match the condition.
      local filename = vim.api.nvim_buf_get_name(0)
      local ctx = { filename = filename, dirname = vim.fs.dirname(filename) }
      names = vim.tbl_filter(function(name)
        local linter = lint.linters[name] ---@type lint.Linter|Linter|fun():Linter|lint.Linter
        if not linter then notifications.warn("Linter not found: " .. name, { title = "nvim-lint" }) end
        return linter and not (type(linter) == "table" and linter.condition and not linter.condition(ctx))
      end, names)
      if #names <= 0 then return end
      return lint.try_lint(names) -- Run linters.
    end

    vim.api.nvim_create_autocmd(opts.events, {
      group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
      callback = debounce(100, dolint),
    })
  end,
}
