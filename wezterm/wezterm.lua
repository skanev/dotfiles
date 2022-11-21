local wezterm = require('wezterm')
local appearance = require('appearance')

wezterm.on('custom-copy', function (window, pane)
  if pane:get_title() == 'tmux' then
    window:perform_action(wezterm.action.SendKey { key = 'c', mods = 'ALT' }, pane)
  else
    window:perform_action(wezterm.action.CopyTo('Clipboard'), pane)
  end
end)

wezterm.on('custom-paste', function (window, pane)
  if pane:get_title() == 'tmux' then
    window:perform_action(wezterm.action.SendKey { key = 'v', mods = 'ALT' }, pane)
  else
    window:perform_action(wezterm.action.PasteFrom('Clipboard'), pane)
  end
end)

return {
  font = appearance.font.font,
  font_size = appearance.font.font_size,
  line_height = appearance.font.line_height,
  audible_bell = 'Disabled',
  visual_bell = {
    fade_in_function = 'EaseIn',
    fade_in_duration_ms = 100,
    fade_out_function = 'EaseOut',
    fade_out_duration_ms = 100,
  },
  disable_default_key_bindings = true,
  keys = require('keys').keys {
    {key = '-', mods = 'MOD', action = wezterm.action.DecreaseFontSize},
    {key = '=', mods = 'MOD', action = wezterm.action.IncreaseFontSize},
    {key = '0', mods = 'MOD', action = wezterm.action.ResetFontSize},

    {key = 'c', mods = 'MOD', action = wezterm.action.EmitEvent('custom-copy')},
    {key = 'v', mods = 'MOD', action = wezterm.action.EmitEvent('custom-paste')},

    {key = 'c', mods = 'CTRL|SHIFT', action = wezterm.action.CopyTo('Clipboard')},
    {key = 'v', mods = 'CTRL|SHIFT', action = wezterm.action.PasteFrom('Clipboard')},
    {key = 't', mods = 'CTRL|SHIFT', action = wezterm.action.SpawnTab('CurrentPaneDomain')},
    {key = 'n', mods = 'CTRL|SHIFT', action = wezterm.action.SpawnWindow},
    {key = ' ', mods = 'CTRL|SHIFT', action = wezterm.action.QuickSelect},
    {key = 'r', mods = 'CTRL|SHIFT', action = wezterm.action.ShowLauncher},

    {key = 'PageUp',   mods = 'SHIFT', action = wezterm.action.ScrollByPage(-1)},
    {key = 'PageDown', mods = 'SHIFT', action = wezterm.action.ScrollByPage(1)},

    {key = 'l', mods = 'CTRL|SHIFT', action = wezterm.action.ShowDebugOverlay},
  },
  hide_tab_bar_if_only_one_tab = true,
  window_padding = appearance.window_padding,
  adjust_window_size_when_changing_font_size = false,
  colors = {
    cursor_bg = '#ffffff',
    cursor_fg = '#000000',
    cursor_border = '#ffffff',
    visual_bell = '#707070',
  },
}
