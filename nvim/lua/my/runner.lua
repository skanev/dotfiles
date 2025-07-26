local utils = require('my.runner.utils')

local fail = utils.fail
local report_error = utils.report_error

local targets = {
  tmux = require('my.runner.tmux').target,
  terminal = require('my.runner.terminal').target,
}

local last_command = nil

local function execute_in_target(command)
  local execute

  if targets.tmux.available() then
    execute = targets.tmux.execute
  else
    execute = targets.terminal.execute
  end

  last_command = command

  local ok, result = pcall(execute, command)
  if not ok then
    report_error(result)
  end
end

local function determine_command(kind)
  local runner = vim.b.runner_spec

  if not runner then return false, 'No runner for current file' end
  if not runner[kind] then return false, 'No runner for ' .. kind .. ' in current file' end

  local file = vim.api.nvim_buf_get_name(0)

  if type(runner[kind]) == 'string' then
    return true, runner[kind]:gsub('{file}', file):gsub('{line}', vim.api.nvim_win_get_cursor(0)[1])
  elseif type(runner[kind]) == 'function' then
    return true, runner[kind](file)
  else
    fail('Unknown type: ' .. vim.inspect(runner[kind]))
  end
end

local function run(kind)
  local ok, command = determine_command(kind)

  if ok then
    execute_in_target(command)
  else
    report_error(command)
  end
end

local function run_file_or_last()
  local ok, command = determine_command('file')

  if ok then
    execute_in_target(command)
  elseif last_command then
    execute_in_target(last_command)
  else
    report_error(command)
  end
end

return {
  run_file = function() run('file') end,
  run_line = function() run('line') end,
  run_file_or_last = run_file_or_last,
  set_buf_runner = function(spec) vim.b.runner_spec = spec end
}
