local util = require('mine.util')

_G._Mine = _G._Mine or {}
_Mine.diagnostic_level = _Mine.diagnostic_level or 'full'

local levels = { 'full', 'light', 'none' }

local function set_diagnostic_level(level)
  local severity

  if level == 'full' then
    severity = { min = vim.diagnostic.severity.HINT }
  elseif level == 'light' then
    severity = { min = vim.diagnostic.severity.ERROR }
  elseif level == 'none' then
    severity = { min = vim.diagnostic.severity.ERROR, max = vim.diagnostic.severity.HINT }
  end

  vim.diagnostic.config {
    underline = { severity = severity },
    virtual_text = { severity = severity },
    signs = { severity = severity },
  }

  _Mine.diagnostic_level = level
end

local function cycle_diagnostics()
  local index = util.index_of(levels, _Mine.diagnostic_level or 'full')
  local next_index

  if index == #levels then
    next_index = 1
  else
    next_index = index + 1
  end

  local next_level = levels[next_index]
  print(string.format("diagnostic level: %s", next_level))
  set_diagnostic_level(next_level)
end

return {
  set_diagnostic_level = set_diagnostic_level,
  cycle_diagnostics = cycle_diagnostics,
  diagnostic_level = function() return _Mine.diagnostic_level end
}
