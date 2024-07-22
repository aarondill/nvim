local M = {}

local api = vim.api
local ms = vim.lsp.protocol.Methods

---@param opts? vim.lsp.buf.code_action.Opts
---@param a lsp.Command|lsp.CodeAction
local function action_filter(opts, a)
  if not opts then return true end

  -- filter by specified action kind
  if opts.context and opts.context.only then
    if not a.kind then return false end
    local found = false
    for _, o in ipairs(opts.context.only) do
      -- action kinds are hierarchical with . as a separator: when requesting only 'type-annotate'
      -- this filter allows both 'type-annotate' and 'type-annotate.foo', for example
      if a.kind == o or vim.startswith(a.kind, o .. ".") then
        found = true
        break
      end
    end
    if not found then return false end
  end
  -- filter by user function
  if opts.filter and not opts.filter(a) then return false end
  -- no filter removed this action
  return true
end

---@param results table<integer, vim.lsp.CodeActionResultEntry>
---@param opts? vim.lsp.buf.code_action.Opts
---@param done fun()
local function on_code_action_results(results, opts, done)
  ---@type {action: lsp.Command|lsp.CodeAction, ctx: lsp.HandlerContext}[]
  local actions = vim
    .iter(results)
    :map(function(result) ---@param result vim.lsp.CodeActionResultEntry
      return vim
        .iter(result.result or {})
        :filter(function(action) return action_filter(opts, action) end)
        :map(function(action) return { action = action, ctx = result.ctx } end)
        :totable()
    end)
    :flatten(1)
    :totable()
  local remaining = #actions
  if remaining == 0 then return done() end
  local function finish_action()
    remaining = remaining - 1
    if remaining == 0 then done() end
  end

  ---@param action lsp.Command|lsp.CodeAction
  ---@param client vim.lsp.Client
  ---@param ctx lsp.HandlerContext
  local function apply_action(action, client, ctx)
    if action.edit then vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding) end
    if not action.command then return end
    local command = type(action.command) == "table" and action.command or action
    ---@diagnostic disable-next-line: param-type-mismatch
    client:_exec_cmd(command, ctx, finish_action)
  end

  for _, choice in ipairs(actions) do
    local client = assert(vim.lsp.get_client_by_id(choice.ctx.client_id))
    local bufnr = assert(choice.ctx.bufnr, "Must have buffer number")
    local action = choice.action

    local reg = client.dynamic_capabilities:get(ms.textDocument_codeAction, { bufnr = bufnr })

    local supports_resolve = vim.tbl_get(reg or {}, "registerOptions", "resolveProvider")
      or client.supports_method(ms.codeAction_resolve)

    if not action.edit and client and supports_resolve then
      client.request(ms.codeAction_resolve, action, function(err, resolved_action)
        if not err then return apply_action(resolved_action, client, choice.ctx) end
        if action.command then return apply_action(action, client, choice.ctx) end
        vim.notify(err.code .. ": " .. err.message, vim.log.levels.ERROR)
        return finish_action()
      end, bufnr)
    else
      apply_action(action, client, choice.ctx)
    end
  end
end

--- Like vim.lsp.buf.code_action, but offers a done callback to be called when all actions are done
--- Also, calls each action found without user interaction
---@param opts vim.lsp.buf.code_action.Opts
---@param done fun()
function M.code_action(opts, done)
  local bufnr = api.nvim_get_current_buf()
  opts = opts or {}

  local context = opts.context or {}
  context.triggerKind = context.triggerKind or vim.lsp.protocol.CodeActionTriggerKind.Invoked
  context.diagnostics = context.diagnostics or {}

  local clients = vim.lsp.get_clients({ bufnr = bufnr, method = ms.textDocument_codeAction })
  local remaining = #clients
  -- if no clients that support code actions, return
  if remaining == 0 then return done() end

  ---@type table<integer, vim.lsp.CodeActionResultEntry>
  local results = {}

  ---@param err? lsp.ResponseError
  ---@param result? (lsp.Command|lsp.CodeAction)[]
  ---@param ctx lsp.HandlerContext
  local function on_result(err, result, ctx)
    results[ctx.client_id] = { error = err, result = result, ctx = ctx }
    remaining = remaining - 1
    if remaining == 0 then on_code_action_results(results, opts, done) end
  end

  for _, client in ipairs(clients) do
    ---@type lsp.CodeActionParams
    local params = vim.lsp.util.make_range_params(nil, client.offset_encoding)
    params.context = context
    client.request(ms.textDocument_codeAction, params, on_result, bufnr)
  end
end

---@param opts vim.lsp.buf.code_action.Opts
---@param timeout? number
function M.code_action_sync(opts, timeout)
  local done = false
  M.code_action(opts, function() done = true end)
  vim.wait(timeout or 1000, function() return done end, 10, vim.in_fast_event())
end

--- Organize and remove unused imports
function M.organize_imports()
  M.code_action_sync({ context = { only = { "source.organizeImports", "source.removeUnusedImports" } } })
end
function M.sort_imports() M.code_action_sync({ context = { only = { "source.sortImports" } } }) end
function M.remove_unused_imports() M.code_action_sync({ context = { only = { "source.removeUnusedImports" } } }) end

return M
