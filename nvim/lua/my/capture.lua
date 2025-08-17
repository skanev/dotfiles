local function open_capture()
  if vim.fn.bufexists('CAPTURE') == 0 then
    vim.cmd [[
      tabnew CAPTURE
      setlocal buftype=nofile nobuflisted bufhidden=wipe noswapfile
    ]]
  elseif vim.buflisted('CAPTURE') ~= 0 then
    vim.cmd 'edit CAPTURE'
  else
    vim.cmd 'tabnew CAPTURE'
  end
end

local function capture(command)
  local value = vim.fn.getreg('p')

  vim.cmd(string.format([[
    redir @p
    silent %s
    redir END
  ]], command))

  open_capture()

  vim.cmd [[
    normal "pp
    normal ggdd
  ]]

  vim.fn.setreg('p', value)
end

local function setup()
  vim.api.nvim_create_user_command('Capture', function(opts)
    local command = opts.args

    if command == '' then
      vim.notify('No command provided for Capture', vim.log.levels.WARN)
      return
    end

    capture(command)
  end, {
    nargs = '+',
    complete = 'command',
  })
end

return {
  setup = setup,
  capture = capture,
}
