local M = {}

function M.toggle_signature_help()
  local success, result = pcall(vim.api.nvim_buf_get_var, 0, 'saga_signature_help_win')

  if not success then return end

  local winid = result[1]

  if not success or not winid then return end

  if vim.api.nvim_win_is_valid(winid) then
    vim.api.nvim_win_close(winid, true)
  else
    require('lspsaga.signaturehelp').signature_help()
  end
end

return M
