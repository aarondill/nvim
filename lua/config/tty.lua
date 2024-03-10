local is_tty = require("utils.is_tty")
if not is_tty() then return end
-- If running in tty, set menu transparency to opaque
vim.opt.pumblend = 0
