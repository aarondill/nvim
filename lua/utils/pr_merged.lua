local M = {}
---(Unused)
---@param cmds (string|string[])[] cmds to run
---@param cb fun(success: boolean): any
---@param kill_on_exit boolean? if true (default), kill other processes when one fails
---@return nil
function M.all_success(cmds, cb, kill_on_exit)
  if kill_on_exit==nil then kill_on_exit=true end
  local jobs = {} ---@type table<vim.SystemObj, any>
  local success = true

  for _, c in ipairs(cmds) do -- spawn
    if type(c) == "string" then c = { c } end
    local ok, j
    ok, j = pcall(vim.system, c, { stderr = false, stdout = false }, function(out)
      jobs[j] = nil
      if out.code ~= 0 then success = false end
    end)
    if not ok then
      success = false
      break -- If one fails, stop spawning
    end
    jobs[j] = true
  end

  local check = assert(vim.uv.new_check())
  return check:start(function()
    -- There's still jobs left, and we haven't failed yet, or we should wait for them to finish
    if next(jobs) and (success or not kill_on_exit) then return end
    check:stop()
      for j in pairs(jobs) do
        j:kill("sigterm")
      end
    return cb(success)
  end)
end

---calls cb if all the prs have been merged
---@param repo string 'OWNER/REPO'
---@param pr integer|integer[] the pr number to check if merged
---@param cb fun(): any? called if all given prs are merged -- Note vim.scheduled automatically
function M.pr_merged(repo, pr, cb)
  local idx_slash = repo:find("/")
  assert(idx_slash, "The repo name must contain a slash!")
  assert(not repo:find("/", idx_slash + 1, true), "Only one slash is alloed in the repo name!")
  pr = type(pr) == "table" and pr or { pr } ---@cast pr integer[]

  --- Note: curl cam take multiple arguments. It runs them sequencially
  local cmd = { "curl", "-fI", "-L", "--" }
  for i, p in ipairs(pr) do
    cmd[#cmd+1] = ("https://api.github.com/repos/%s/pulls/%d/merge"):format(repo, p)
  end
  --- Note: the api returns 204 if merged (else 404), so curl will return 0 if merged.
  pcall(vim.system, cmd, { stderr = false, stdout = false }, function(out)
    if out.code ~= 0 then return end
    return vim.schedule(cb)
  end)
end

---warns the user if all the prs have been merged - can now go back to upstream
---@param repo string 'OWNER/REPO'
---@param pr integer|integer[] the pr number to check if merged
function M.on_lazy(repo, pr)
  pr = type(pr) == "table" and pr or { pr } ---@cast pr integer[]
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    once = true,
    callback = function()
      return M.pr_merged(repo, pr, function()
        local msg = table.concat({
          ("The blocking pr(s) #%s in repo %s have been merged!"):format(table.concat(pr, ","), repo),
          "Please change the plugin spec to use the upstream!",
        }, "\n")
        return vim.notify(msg, vim.log.levels.WARN, {
          title = "Use Plugin Upstream!",
        })
      end)
    end,
  })
end

return M
