local wezterm = require('wezterm')
local environment = {}

if wezterm.target_triple:find('darwin') then
  environment.os = 'mac'
  environment.mod = 'CMD'
else
  environment.os = 'linux'
  environment.mod = 'ALT'
end

return environment
