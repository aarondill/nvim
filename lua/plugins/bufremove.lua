-- buffer remove
---@type LazySpec
return {
  "nvim-mini/mini.bufremove",
  keys = {
    {
      "<leader>bd",
      function()
        local bd = require("mini.bufremove").delete
        if not vim.bo.modified then return bd(0) end

        local msg = ("Save changes to %q?"):format(vim.fn.bufname())
        local choice = vim.fn.confirm(msg, "&Yes\n&No\n&Cancel")
        if choice == 3 or choice == 0 then return end -- Cancel
        if choice == 1 then vim.cmd.write() end -- Yes
        local force = choice == 2
        return bd(0, force)
      end,
      desc = "Delete Buffer",
    },
    { "<leader>bD", function() require("mini.bufremove").delete(0, true) end, desc = "Delete Buffer (Force)" },
  },
}
