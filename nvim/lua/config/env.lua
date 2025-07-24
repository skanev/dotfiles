local env = {}

env.wsl = vim.env.WSLENV ~= nil

if vim.fn.has('gui_running') == 1 then
  if vim.g.neovide then env.app = 'neovide'
  else                  env.app = 'unknown-gui'
  end
else
  env.app = 'nvim'
end

local os_name = vim.uv.os_uname().sysname

if os_name == 'Linux' then env.os = 'linux'
elseif os_name == 'Darwin' then env.os = 'mac'
else env.os = 'unknown'
end

env.tmux = vim.env.TMUX ~= nil and env.app == 'nvim'

if env.os == 'mac' and env.app == 'neovide' then
  env.meta_key = 'D'
else
  env.meta_key = 'M'
end

vim.api.nvim_create_user_command(
  'DisplayEnv',
  function() vim.print(env) end,
  { nargs = 0 }
)

return env
