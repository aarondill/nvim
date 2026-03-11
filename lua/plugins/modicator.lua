---@type LazySpec
return {
  {
    "mvllow/modes.nvim",
    event = { "ModeChanged", "LazyFile" },
    -- Load modicator first to match the highlight groups
    dependencies = { { "mawkler/modicator.nvim", optional = true } },
    config = function(_, opts)
      local function copy_highlights()
        for _, links in ipairs({
          { "ModesInsert", "InsertMode" },
          { "ModesVisual", "VisualMode" },
          { "ModesReplace", "ReplaceMode" },
        }) do
          local hl = vim.api.nvim_get_hl(0, { name = links[2] })
          if not vim.tbl_isempty(hl) then -- Match the background to the Modicator forground
            vim.api.nvim_set_hl(0, links[1], vim.tbl_extend("force", hl, { bg = hl.fg }))
          end
        end
        -- Recall setup to apply the new highlights
        require("modes").setup(opts)
      end
      vim.api.nvim_create_autocmd({ "ModeChanged", "ColorScheme" }, {
        callback = copy_highlights,
        desc = "Copy highlight groups from Modicator",
      })
      copy_highlights()
    end,
    opts = {
      set_number = false,
      set_signcolumn = false,
    },
  },
  {
    "mawkler/modicator.nvim",
    init = function()
      -- These are required for Modicator to work
      vim.o.cursorline, vim.o.number, vim.o.termguicolors = true, true, true
    end,
    event = { "ModeChanged", "LazyFile" },
    opts = {},
  },
}
