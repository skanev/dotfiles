local WINDOW_NAME = 'QuickTerminal'

local function toggle_quick_terminal()
  local id = vim.fn.bufnr(WINDOW_NAME)

  local window_id = nil
  local current_id = vim.fn.win_getid()

  local tabinfo = vim.fn.gettabinfo(vim.fn.tabpagenr())
  local window_ids = tabinfo[1].windows

  local vertical = vim.o.columns >= 150
  local options

  if vertical then
    options = {
      resize = 'vertical resize ' .. (vim.o.columns / 2),
      split = 'botright vertical',
    }
  else
    options = {
      resize = 'resize ' .. (vim.o.lines / 2),
      split = 'botright',
    }
  end

  for _, win in ipairs(window_ids) do
    if vim.api.nvim_win_get_buf(win) == id then
      window_id = win
      break
    end
  end

  -- No terminal buffer exists
  if id == -1 then
    vim.api.nvim_command(options.split .. ' split | ' .. options.resize .. ' | terminal')
    vim.api.nvim_buf_set_name(0, WINDOW_NAME)
    vim.wo.number = false
    vim.wo.winhl = 'Normal:NvimTreeNormal'
    vim.api.nvim_command('startinsert')

  -- Terminal buffer exists and currently in it
  elseif current_id == window_id then
    vim.api.nvim_command('close')

  -- Terminal buffer is open in another window on the current tab
  elseif window_id then
    vim.api.nvim_command(vim.fn.win_id2win(window_id) .. 'wincmd w | startinsert')

  -- Terminal buffer exists, but hidden
  else
    vim.api.nvim_command(options.split .. ' sbuffer ' .. id .. ' | ' .. options.resize .. ' | startinsert')
  end
end

vim.keymap.set({'n', 't'}, '<Plug>(quickterminal)', toggle_quick_terminal, { noremap = false })

return {
  toggle = toggle_quick_terminal,
}
