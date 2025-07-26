local utils = require('my.runner.utils')
local shell = utils.shell
local fail = utils.fail

local M = {}

local function tmux_escape_keys(text)
  return "'" .. text:gsub("'", "\\\\'") .. "'"
end

local function tmux_session_status()
  local sessions = shell("tmux list-sessions -F '#S'")
  local target_session = vim.fn.fnamemodify(vim.fn.getcwd(), ':t')

  return target_session, vim.tbl_contains(sessions, target_session)
end

M.target = {
  available = function()
    local _, ok = tmux_session_status()
    return ok
  end,

  execute = function(command)
    local target_session, started = tmux_session_status()

    if not started then
      fail('tmux does not have a ' .. target_session .. ' session')
    end

    local matches = shell("tmux list-panes -F '#{pane_current_command};#{pane_mode}' -f '#{==:#P,0}' -t %s:1", target_session)

    if #matches == 0 then fail('runner: could not find a pane to run in')
    elseif #matches == 2 then fail('runner: somehow found too many panes to run in: ' .. table.concat(matches, ', '))
    end

    local tmux_target = string.format("%s:1.0", target_session)
    local parts = vim.split(matches[1], ';')
    local current_command = parts[1]

    if current_command ~= 'zsh' then
      fail(string.format("runner: target pane in %s not running zsh, but: %s", target_session, current_command))
    end

    if parts[2] ~= '' then
      shell('tmux copy-mode -q -t %s:1.0', target_session)
    end

    shell('tmux select-window -t %s \\; send-keys -t %s C-u C-l %s C-m', tmux_target, tmux_target, tmux_escape_keys(command))
  end
}

return M
