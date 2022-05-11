local M = {}

local function strip_ansi_codes(text)
  return vim.fn.substitute(text, [=[\e\[[0-9;:]*[mGK]]=], '', 'g')
end

--- Shows a window that is centered that displays ansi escaped text
function M.float_window_with_ansi_codes(text)
  local lines = vim.split(text, "\n")

  local bufid = vim.api.nvim_create_buf(false, true)
  local chanid = vim.api.nvim_open_term(bufid, {})

  local width = 20
  local height = #lines

  for _, line in ipairs(lines) do
    local stripped = strip_ansi_codes(line)
    width = math.max(width, #stripped)
    vim.api.nvim_chan_send(chanid, line .. "\r\n")
  end

  if lines[#lines] == '' then height = height - 1 end

  width = math.max(40, width)
  height = math.max(3, height)

  width = math.min(width, vim.o.columns - 6)
  height = math.min(height, vim.o.lines - 4)

  local winid = vim.api.nvim_open_win(bufid, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height - 2) / 2),
    col = math.floor((vim.o.columns - width - 2) / 2),
    style = 'minimal',
    border = 'rounded',
  })

  vim.api.nvim_win_set_option(winid, 'scrolloff', 0)

  vim.api.nvim_buf_set_option(bufid, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_keymap(bufid, 'n', 'q', '<Cmd>close<CR>', { nowait = true, noremap = true })
  vim.api.nvim_buf_set_keymap(bufid, 'n', '<C-c>', '<Cmd>close<CR>', { nowait = true, noremap = true })
  vim.api.nvim_buf_set_keymap(bufid, 'n', '<Esc>', '<Cmd>close<CR>', { nowait = true, noremap = true })

  local autocmds = {}

  local function clear_autocmds()
    for _, auid in ipairs(autocmds) do
      vim.api.nvim_del_autocmd(auid)
    end
  end

  table.insert(autocmds, vim.api.nvim_create_autocmd({ 'BufLeave' }, {
    buffer = bufid,
    callback = function()
      vim.api.nvim_win_close(winid, false)
      clear_autocmds()
    end
  }))

  table.insert(autocmds, vim.api.nvim_create_autocmd({ 'TermEnter' }, {
    buffer = bufid,
    callback = function()
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-\\><C-n>', true, false, true), 'n', false)
    end
  }))

  vim.api.nvim_win_set_option(winid, 'winhl', 'Normal:Normal,FloatBorder:ModeMsg,EndOfBuffer:FloatShadow')
end

return M
