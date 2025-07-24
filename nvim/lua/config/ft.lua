local M = {}

local group = vim.api.nvim_create_augroup('my_ftplugin', { clear = true })

vim.api.nvim_create_user_command("E", function()
  vim.cmd [[
    doautocmd <nomodeline> User ResetCustomizations
    edit
  ]]
end, {})

vim.api.nvim_create_user_command("MyFtplugin", function(opts)
  local name = nil

  if opts.args ~= "" then
    name = opts.args
  elseif vim.bo.filetype ~= "" then
    name = vim.bo.filetype
  else
    error('Current buffer has no filetype')
  end

  local filename = vim.fn.expand('~/.config/nvim/ftplugin/' .. name .. '.lua')

  vim.cmd('split ' .. filename)

  if vim.fn.filereadable(filename) == 0 then
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {
      'require("config.ft").once {}'
    })
  end

end, {
  nargs = '?',
  complete = function(arglead)
    local files = vim.fn.readdir(vim.fn.expand('~/.config/nvim/ftplugin'))
    local plugins = {}

    for _, file in ipairs(files) do
      local name = vim.fn.fnamemodify(file, ':t:r')
      if vim.startswith(name, arglead) then
        table.insert(plugins, name)
      end
    end

    return plugins
  end
})

vim.api.nvim_create_autocmd('User', {
  pattern = 'ResetCustomizations',
  group = group,
  callback = function()
    vim.b.did_my_ftplugin = nil
  end,
})

function M.once(callback)
  if vim.b.did_my_ftplugin then
    return
  end

  if type(callback) == 'function' then
    callback()
  elseif type(callback) == 'table' then
    if callback.tabs then
      vim.bo.tabstop = callback.tabs
      vim.bo.softtabstop = callback.tabs
      vim.bo.shiftwidth = callback.tabs
      vim.bo.expandtab = true
    end
  else
    error("Unknown value for callback: " .. tostring(callback))
  end

  vim.b.did_my_ftplugin = true
end

return M
