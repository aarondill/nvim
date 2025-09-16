-- Return the right icon set depending on is_tty
-- Note: gui module will handle the metatable magic itself
return not require("utils").is_tty() and require("config.icons.gui") or require("config.icons.tty")
