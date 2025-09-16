if not require("utils").is_tty() then return end
-- If running in tty, set menu transparency to opaque
vim.o.pumblend = 0
