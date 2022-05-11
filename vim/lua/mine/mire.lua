local Job = require("plenary.job")
local u = require("mine.util")

_G._Mire = _G._Mire or {}

local hl = {
  error_sign = 'Red',
  error_hint = 'ErrorMsg',
}

--- Applies failures to a specific buffer
-- Puts the relevant signs for all the failures it has been given.
--
-- Failures are provided in the following format:
--
-- {
--        example_start_line = 1,                 -- the "it" line of the failed example
--        failure_line = 3,                       -- the line on which the example failed
--        failure_hint = '1 == 2',                -- virtual text to show on the failure line
--        failure_message = "1 == 2 is not true", -- the full message
-- }
--
-- @param bufnr the buffer to apply it to
-- @param failures an array of the failures
local function apply_failures(bufnr, failures)
  local nsid = vim.api.nvim_create_namespace('fire')

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  local failure_lines = {}

  for _, error in ipairs(failures) do
    local line = lines[error.example_start_line]
    local first = (line:find('%S') or 0) - 1
    local last = #line

    failure_lines[tostring(error.example_start_line)] = error.failure_message
    failure_lines[tostring(error.failure_line)] = error.failure_message

    vim.api.nvim_buf_set_extmark(bufnr, nsid, error.example_start_line - 1, first, {
      end_col = last,
      sign_text = ":(",
      sign_hl_group = hl.error_sign,
      priority = 200,
    })

    line = lines[error.failure_line]
    first = (line:find('%S') or 1) - 1
    last = #line
    vim.api.nvim_buf_set_extmark(bufnr, nsid, error.failure_line - 1, first, {
      end_col = last,
      virt_text = { { ' >>  ', 'NonText' }, { error.failure_hint, hl.error_hint } },
      priority = 200,
    })
  end

  vim.api.nvim_buf_set_var(bufnr, 'mire_failure_messages', failure_lines)
end

--- Applies coverage data in a specific buffer.
--
-- Applies extmarks to indicate which lines have what coverage. Lines contains
-- all the lines of the files as the test saw them. This is useful to compare
-- against what's actually in the buffer in order to not indicate incorrectly.
--
-- Lines are specified in the following format:
--
-- {
--   { 0, "uncovered line" },
--   { vim.NIL, "irrelevant line" },
--   { 2, "line covered by two runs"},
-- }
-- @param bufnr the buffer to apply to
-- @param lines an array of lines with coverage data
local function apply_coverage(bufnr, lines)
  local nsid = vim.api.nvim_create_namespace('fire')

  for i, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)) do
    local hits = lines[i][1]

    local highlight = ''

    if line ~= lines[i][2] then
      highlight = 'BlueSign'
    elseif hits == vim.NIL or hits == nil then
      highlight = 'GreenSign'
    elseif hits == 0 then
      highlight = 'RedSign'
    else
      highlight = 'GreenSign'
    end

    vim.api.nvim_buf_set_extmark(bufnr, nsid, i - 1, 0, {
      number_hl_group = highlight,
      priority = 210,
    })
  end
end

--- Applies a mire event
-- @param event the mire event JSON
local function apply_event(event)
  local nsid = vim.api.nvim_create_namespace('fire')
  local simplecov = u.index_by(event.simplecov, function(e) return e.name end)

  for _, buffer in ipairs(vim.fn.getbufinfo({ bufloaded = true })) do
    vim.api.nvim_buf_clear_namespace(buffer.bufnr, nsid, 0, -1)

    if buffer.name == event.file then
      apply_failures(buffer.bufnr, u.map(event.failures, function(failure)
        return {
          example_start_line = failure.line,
          -- This assumes the failure is in the last element of the stacktrace, but that may not be true
          failure_line = failure.stacktrace[#failure.stacktrace][2],
          failure_hint = failure.message_hint,
          failure_message = failure.message,
        }
      end))
    end

    if simplecov[buffer.name] then
      local data = simplecov[buffer.name]
      apply_coverage(buffer.bufnr, data.lines)
    end
  end
end

local function undo_mire_extmarks()
  local nsid = vim.api.nvim_create_namespace('fire')

  for _, buffer in ipairs(vim.fn.getbufinfo()) do
    vim.api.nvim_buf_clear_namespace(buffer.bufnr, nsid, 0, -1)
  end
end

--- Mire job callback
--
-- The callback invoked by the job listening to mire. It received a string it
-- needs to handle. Declared separately so it cal be overriden without
-- restarting the mire job.
local function mire_job_callback(data)
  if data ~= nil then
    local success, json = pcall(vim.json.decode, data)

    if success then
      if type(json) == 'table' and json.type == 'mire' then
        vim.defer_fn(function() apply_event(json) end, 0)
      end
    else
      vim.api.nvim_err_writeln("Got bad input from mire: " .. data)
    end
  end
end

--- Show info under cursor
--
-- If there is a relevant event under the cursor, show it
local function show_info_under_cursor()
  local message = (vim.b.mire_failure_messages or {})[tostring(vim.fn.line('.'))]
  if message then
    require('mine.util.float').float_window_with_ansi_codes(message)
  end
end

_G._Mire.job_callback = mire_job_callback

--- Starts a mire job
--
-- Starts a plenary job to listen to mire pubsub listen. It's stored in a
-- global table and looks for its callback there. That way this whole file can
-- be reloaded without restarting the job.
local function start_mire_job(force)
  local existing_job = _G._Mire.job

  if existing_job and not force then
    return
  end

  if existing_job then
    vim.loop.kill(existing_job.pid)
  end

  local job = Job:new {
    command = '/usr/bin/env',
    args = { 'zsh', '-c', '~/.scripts/mire pubsub listen' },
    on_stdout = function(_, data)
      if data ~= nil then
        _G._Mire.job_callback(data)
      end
    end,
  }

  _G._Mire.job = job

  job:start()
end

--- Stops the mire job
--
-- Kills it if necessary
local function stop_mire_job()
  local job = _G._Mire.job

  if not job then return end

  vim.loop.kill(job.pid)
  _G._Mire.job = nil
end

vim.api.nvim_create_user_command('MireStart', [[lua require('mine.mire').start(true)]], { nargs = 0 })
vim.api.nvim_create_user_command('MireStop', [[lua require('mine.mire').stop()]], { nargs = 0 })
vim.api.nvim_create_user_command('MireShowInfo', [[lua require('mine.mire').show_info_under_cursor()]], { nargs = 0 })

return {
  start = start_mire_job,
  show_info_under_cursor = show_info_under_cursor,
  stop = function()
    stop_mire_job()
    undo_mire_extmarks()
  end
}
