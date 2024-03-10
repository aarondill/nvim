-- This is so root files don't get written to the home directory of another user.
---@param user string|integer the username or id of the user
local function getent(user)
  if type(user) == "number" then user = tostring(user) end -- getent handles ids
  ---@cast user string
  -- get the passwd line for root
  -- errors if getent is not available
  local ret = vim.system({ "getent", "passwd", user }):wait()
  if ret.signal > 0 or ret.code > 0 or not ret.stdout then
    local msg = "getent failed"
    if ret.stderr then msg = string.format("%s: %s", msg, ret.stderr) end
    error(msg)
  end
  -- get the home from the colon seperated list
  local line = ret.stdout:match("^(.*)\n")
  local _, _, _, _, _, home, _ = line:match("^(.-):(.-):(.-):(.-):(.-):(.-):(.-)$")
  if not home then error("getent parsing failed") end
  return home
end

---@param user string|integer the username or id of the user
local function perl(user)
  local script = [[
  use User::pwent;
  print getpw($ARGV[0])->dir; # this handles integers and strings
  ]]
  local ret = vim.system({ "perl", "-e", script, tostring(user) }):wait()
  if ret.signal > 0 or ret.code > 0 or not ret.stdout then
    local msg = "perl script failed"
    if ret.stderr then msg = string.format("%s: %s", msg, ret.stderr) end
    error(msg)
  end
  return ret.stdout:match("^(.*)\n?") -- first line
end

---@param find_user string|integer the username or id of the user
local function parse_etc_passwd(find_user)
  if not vim.uv.fs_access("/etc/passwd", "R") then error("/etc/passwd is not readable") end
  local file = io.open("/etc/passwd", "r")
  if not file then error("open /etc/passwd failed") end
  for line in file:lines("*l") do
    local name, _, id, _, _, home, _ = line:match("^(.-):(.-):(.-):(.-):(.-):(.-):(.-)$")
    -- if parsing fails, these checks silently fail
    if type(find_user) == "string" and name == find_user then
      return home
    elseif type(find_user) == "number" and tonumber(id) == find_user then
      return home
    end
  end
  error("user not found in /etc/passwd")
end

if os.getenv("USER") ~= "root" then return true end -- I am not root
if not os.getenv("HOME") then return false end -- $HOME is not defined
---These should all return root's home of their first argument (username), or error if not found/failed
local fallbacks = { getent, perl, parse_etc_passwd }
for _, f in ipairs(fallbacks) do
  ---@type boolean, string?
  local ok, home = pcall(f, os.getenv("USER"))
  if ok and type(home) == "string" and #home > 0 then
    -- $HOME is the same as the root's actual home.
    return os.getenv("HOME") == home
  end
end

return true -- Couldn't figure it out.
