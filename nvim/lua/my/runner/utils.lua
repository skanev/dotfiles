local M = {}

local function expand(message, ...)
  if select('#', ...) ~= 0 then
    return message:format(...)
  else
    return message
  end
end

local function call_system(command)
  local oldshell = vim.opt.shell
  vim.opt.shell = '/bin/dash'
  local result = vim.fn.system(command)
  vim.opt.shell = oldshell
  return result, vim.v.shell_error
end

function M.fail(message, ...)
  if select('#', ...) ~= 0 then
    message = message:format(message, ...)
  end

  error(expand(message, ...), 0)
end

function M.report_error(text, ...)
  vim.api.nvim_echo({ { expand(text, ...), 'ErrorMsg' } }, true, {})
end

function M.shell(command, ...)
  command = expand(command, ...)

  local result, code = call_system(command)

  if code ~= 0 then
    M.report_error('shell failed with: ' .. code)
    M.report_error(result)
    M.fail('shell failed')
  end

  return vim.split(result, "\n", { trimempty = true })
end

return M
