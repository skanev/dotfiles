local M = {}

local function signature_help_window()
  local success, result = pcall(vim.api.nvim_buf_get_var, 0, 'saga_signature_help_win')

  if not success then return end

  local winid = result[1]

  if not winid then return end

  if vim.api.nvim_win_is_valid(winid) then
    return winid
  else
    return
  end
end

function M.hide_signature_help()
  local winid = signature_help_window()

  if winid then
    vim.api.nvim_win_close(winid, true)
  end
end

function M.toggle_signature_help()
  local winid = signature_help_window()

  if winid then
    vim.api.nvim_win_close(winid, true)
  else
    if vim.fn.pumvisible() == 1 then
      vim.fn.complete(vim.fn.col('.'), {})
    end
    require('lspsaga.signaturehelp').signature_help()
  end
end

function M.cycle_diagnostics()
  require('mine.diagnostics').cycle_diagnostics()
end

return M
