local picker = require("utils").picker

local function vpicker(m)
  local f = picker(m)
  return function() f({ search = require("utils").vtext() }) end
end

---@type LazySpec
return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      files = {
        hidden = true,
        ignored = true,
      },
    },
  },
  init = function()
    if vim.fn.argc() == 0 then -- if no args, then open the files
      local read_from_stdin = false
      require("utils.create_autocmd")("StdinReadPre", function()
        read_from_stdin = true -- don't open treesitter on reading from stdin
      end)
      require("utils.create_autocmd")("VimEnter", function()
        if read_from_stdin then return end
        vim.defer_fn(picker("files"), 0)
      end)
    end
  end,
  keys = {
    { "<leader>:", picker("command_history"), desc = "Command History" },
    { "<leader><space>", picker("files"), desc = "Find Files (root dir)" },
    { "<leader>ff", picker("files"), desc = "Find Files (root dir)" },
    { "<leader>fb", picker("buffers"), desc = "Buffers" },
    { "<leader>fg", picker("git_files"), desc = "Find Files (git-files)" },
    { "<leader>fr", picker("recent"), desc = "Recent" },
    { "<leader>gc", picker("git_log"), desc = "commits" },
    { "<leader>sa", picker("autocmds"), desc = "Auto Commands" },
    { "<leader>sC", picker("commands"), desc = "Commands" },
    { "<leader>sD", picker("diagnostics"), desc = "Workspace diagnostics" },
    { "<leader>sh", picker("help"), desc = "Help Pages" },
    { "<leader>sH", picker("highlights"), desc = "Search Highlight Groups" },
    { "<leader>sk", picker("keymaps"), desc = "Key Maps" },
    { "<leader>sM", picker("man"), desc = "Man Pages" },
    { "<leader>sm", picker("marks"), desc = "Jump to Mark" },
    { "<leader>sc", picker("colorschemes"), desc = "Colorscheme with preview" },
    { "<leader>sw", picker("grep_word"), desc = "Word (root dir)" },
    { "<leader>sw", vpicker("grep"), mode = "v", desc = "Selection (root dir)" },
    { "<leader>/", picker("grep"), desc = "Grep (root dir)" },
    { "<leader>/", vpicker("grep"), mode = "v", desc = "Selection (root dir)" },
    { "<C-/>", picker("grep_word"), desc = "Word (root dir)" },
    { "<C-/>", vpicker("grep"), mode = "v", desc = "Selection (root dir)" },
  },
}
