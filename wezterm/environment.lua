local wezterm = require('wezterm')
local environment = {}

if wezterm.target_triple:find('darwin') then
  environment.os = 'mac'
  environment.mod = 'CMD'
elseif wezterm.target_triple:find('windows') then
  environment.os = 'windows'
  environment.mod = 'ALT'
else
  environment.os = 'linux'
  environment.mod = 'ALT'
end

return environment
