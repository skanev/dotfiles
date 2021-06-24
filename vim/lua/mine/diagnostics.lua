local util = require('mine.util')
local log = require('mine.log')

_I = _I or {}
_I.last_diagnostics = _I.last_diagnostics or {}
_I.diagnostic_level = _I.diagnostic_level or 'full'

local levels = { 'full', 'light', 'none' }

local function set_diagnostic_level(level)
  local original_handler = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
      virtual_text = true,
      signs = true,
      underline = true,
      update_in_insert = false,
    }
  )

  local handler = function(what, name, data, how)
    _I.last_diagnostics[vim.api.nvim_get_current_buf()] = { what, name, data, how }
    ----log.info(vim.inspect(data))

    data = util.shallow_copy(data)

    data.diagnostics = util.filter(data.diagnostics, function(item)
      if level == 'none' then
        return false
      elseif level == 'light' then
        return item.severity == 1
      elseif level == 'full' then
        return true
      else
        log.warn("Unknown severity level " .. tostring(level))
        return true
      end
    end)

    original_handler(what, name, data, how)
  end

  vim.lsp.handlers["textDocument/publishDiagnostics"] = handler

  local last_diagnostics = _I.last_diagnostics[vim.api.nvim_get_current_buf()]

  if last_diagnostics then
    handler(unpack(last_diagnostics))
  end

  _I.diagnostic_level = level
end

local function cycle_diagnostics()
  local index = util.index_of(levels, _I.diagnostic_level or 'full')
  local next_index

  if index == #levels then
    next_index = 1
  else
    next_index = index + 1
  end

  local next_level = levels[next_index]
  vim.cmd(string.format("echo 'diagnostic level: %s'", next_level))
  set_diagnostic_level(next_level)
end

return {
  set_diagnostic_level = set_diagnostic_level,
  cycle_diagnostics = cycle_diagnostics,
  diagnostic_level = function() return _I.diagnostic_level end
}
