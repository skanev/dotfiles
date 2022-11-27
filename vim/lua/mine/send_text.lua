local function system(cmd)
  local result = vim.fn['s#system'](cmd)

  if vim.v.shell_error ~= 0 then
    error("Failed to run command: " .. cmd .. "\n\nOutput:\n\n" .. result)
  else
    return result
  end
end

local function system_successful(cmd)
  vim.fn['s#system'](cmd)

  return vim.v.shell_error == 0
end

local function send_text(mode)
  local text

  if mode == 'visual' then
    text = vim.fn['s#selected_text']()
    if text:sub(#text, #text) ~= "\n" then text = text .. "\n" end
  else
    text = vim.fn.join(vim.api.nvim_buf_get_lines(0, 0, -1, true), "\n") .. "\n"
  end

  text = vim.fn.substitute(text, '"', [[\\"]], 'g')

  local target = vim.fn.fnamemodify(vim.fn.getcwd(), ':t')

  if system_successful("tmux has-session -t " .. target) then
    system(string.format('tmux send-keys -t %s "%s"', target, text))
  elseif vim.fn.executable('wezterm') ~= 0 then
    system(string.format('wezterm cli send-text --no-paste -- "%s"', text))
  else
    error("Cannot find what to send text to")
  end
end

vim.keymap.set('n', '<Plug>(mine-send-text-buffer)', function() send_text('normal') end)
vim.keymap.set('v', '<Plug>(mine-send-text-selection)', function() send_text('visual') end)
