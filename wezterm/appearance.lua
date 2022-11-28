local environment = require('environment')
local wezterm = require('wezterm')

local font = {
  font = wezterm.font {
    family = 'CaskaydiaCove Nerd Font',
    harfbuzz_features = {'calt=0', 'clig=0', 'liga=0'},
  },
  font_size = 12.0,
}

local window_padding = { top = 0, left = 0, right = 0, bottom = 0 }

if environment.os == 'mac' then
  font.font_size = 14.0
  font.line_height = 1.1

  window_padding.top = 8
  window_padding.bottom = 6
  window_padding.left = 8
  window_padding.right = 8
elseif environment.os == 'windows' then
  font = {
    font = wezterm.font {
      family = 'Cascadia Code',
      harfbuzz_features = {'calt=0', 'clig=0', 'liga=0'},
    },
    font_size = 12.0,
  }

  window_padding.top = 12
  window_padding.bottom = 12
  window_padding.left = 12
  window_padding.right = 12
else
end

return {
  font = font,
  window_padding = window_padding,
}
