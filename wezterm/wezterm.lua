local wezterm = require('wezterm')
local appearance = require('appearance')
local tmux = require('tmux')
local util = require('util')

wezterm.GLOBAL.sessions = wezterm.GLOBAL.sessions or {}

local OUT_OF_CONTEXT_BACKGROUND = '#191926'
local BLACK_BACKGROUND = '#000000'

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local result = string.format(
    " %s %s ",
    tab.active_pane.is_zoomed and "🔍" or (tab.tab_index + 1),
    tab.active_pane.title
  )

  if tab.tab_index > 0 and not tab.is_active then
    result = " " .. result
  end

  if tabs[tab.tab_index + 2] and tabs[tab.tab_index + 2].is_active then
    result = result .. " "
  end

  return result
end)

wezterm.on('update-status', function (window, pane)
  local active_workspace = window:active_workspace()

  local window_state

  if active_workspace ~= 'default' then
    window_state = 'workspace'
  elseif tmux.is_running_tmux(pane) then
    window_state = 'tmux_in_default'
  else
    window_state = 'default'
  end

  local overrides = window:get_config_overrides() or {}
  local config_state = overrides.color_scheme

  -- tab bar styling
  if window_state == 'workspace' then
    window:set_left_status(wezterm.format {
      { Background = { Color = '#cccccc' } },
      { Foreground = { Color = 'Black' } },
      { Text = string.format(" ❖ %s ", active_workspace) },

      { Background = { Color = '#444444' } },
      { Foreground = { Color = '#999999' } },
      { Text = string.format(" %s ", '-----') }
    })

    window:set_right_status(wezterm.format {
      { Background = { Color = '#444444' } },
      { Foreground = { Color = '#999999' } },
      { Text = string.format(" %s ", wezterm.hostname()) },

      { Background = { Color = '#cccccc' } },
      { Foreground = { Color = 'Black' } },
      { Text = wezterm.strftime(" %H:%M ") },
    })
  else
    window:set_left_status('')
    window:set_right_status('')
  end

  -- switch background color and tab position if necessary
  if config_state == window_state then
    -- do nothing
  elseif window_state == 'default' then
    window:set_config_overrides {
      hide_tab_bar_if_only_one_tab = true,
      tab_bar_at_bottom = false,
      use_fancy_tab_bar = true,
      color_scheme = 'default',
    }
  elseif window_state == 'workspace' then
    window:set_config_overrides {
      hide_tab_bar_if_only_one_tab = false,
      tab_bar_at_bottom = true,
      use_fancy_tab_bar = false,
      color_scheme = 'workspace'
    }
  elseif window_state == 'tmux_in_default' then
    window:set_config_overrides {
      hide_tab_bar_if_only_one_tab = true,
      tab_bar_at_bottom = false,
      use_fancy_tab_bar = true,
      color_scheme = 'tmux_in_default',
    }
  end
end)

wezterm.on('user-var-changed', function (_, pane, name, value)
  if name == 'ExecuteCommand' then
    local command
    local message

    command, message = value:match('^([^:]+):(.+)')

    if command ~= nil then
      wezterm.emit('command:' .. command, message, pane)
    end
  end
end)

wezterm.on('command:ping', function (message)
  wezterm.log_info('ping', message)
end)

wezterm.on('command:into-session', function (message)
  local workspace, cwd = message:match('^(%S+) %-> (.+)')

  if not util.list_contains(wezterm.mux.get_workspace_names(), workspace) then
    wezterm.mux.spawn_window { workspace = workspace, cwd = cwd }

    local sessions = wezterm.GLOBAL.sessions
    sessions[workspace] = cwd
    wezterm.GLOBAL.sessions = sessions
  end

  wezterm.mux.set_active_workspace(workspace)
end)

local mappings = require('keys').keys {
  {
    key = 's',
    mods = 'CTRL',
    action = wezterm.action_callback(function(window, pane)
      if tmux.is_running_tmux(pane) then
        window:perform_action(wezterm.action.SendKey { key = 's', mods = 'CTRL' }, pane)
      else
        window:perform_action(wezterm.action.ActivateKeyTable { name = 'tmux_like', timeout_millisecons = 5000 }, pane)
      end
    end)
  },

  { key = '-', mods = 'MOD', action = wezterm.action.DecreaseFontSize },
  { key = '=', mods = 'MOD', action = wezterm.action.IncreaseFontSize },
  { key = '0', mods = 'MOD', action = wezterm.action.ResetFontSize },

  { key = 'c', mods = 'CTRL|SHIFT', action = wezterm.action.CopyTo('Clipboard') },
  { key = 'v', mods = 'CTRL|SHIFT', action = wezterm.action.PasteFrom('Clipboard') },
  { key = 't', mods = 'CTRL|SHIFT', action = wezterm.action.SpawnTab('CurrentPaneDomain') },

  { key = 'n', mods = 'CTRL|SHIFT', action = wezterm.action.SpawnWindow },
  { key = 'r', mods = 'CTRL|SHIFT', action = wezterm.action.ShowLauncher },

  { key = '1', mods = 'CTRL|MOD', action = wezterm.action.ActivateTab(0) },
  { key = '2', mods = 'CTRL|MOD', action = wezterm.action.ActivateTab(1) },
  { key = '3', mods = 'CTRL|MOD', action = wezterm.action.ActivateTab(2) },
  { key = '4', mods = 'CTRL|MOD', action = wezterm.action.ActivateTab(3) },
  { key = '5', mods = 'CTRL|MOD', action = wezterm.action.ActivateTab(4) },
  { key = '6', mods = 'CTRL|MOD', action = wezterm.action.ActivateTab(5) },
  { key = '7', mods = 'CTRL|MOD', action = wezterm.action.ActivateTab(6) },
  { key = '8', mods = 'CTRL|MOD', action = wezterm.action.ActivateTab(7) },
  { key = '9', mods = 'CTRL|MOD', action = wezterm.action.ActivateTab(8) },

  { key = 'l', mods = 'CTRL|SHIFT', action = wezterm.action.ShowDebugOverlay },

  { key = 'PageUp',   mods = 'SHIFT', action = wezterm.action.ScrollByPage(-1) },
  { key = 'PageDown', mods = 'SHIFT', action = wezterm.action.ScrollByPage(1) },

  { special = 'leader', mods = 'CTRL', key = 's', action = wezterm.action.SendKey { key = 's', mods = 'CTRL' } },

  { special = 'leader', key = 'j', action = wezterm.action.QuickSelect },
  { special = 'leader', key = 'n', action = wezterm.action.SpawnWindow },
  { special = 'leader', key = 'p', action = wezterm.action.PaneSelect },
  { special = 'leader', key = 'q', action = wezterm.action.ActivateCopyMode },
  { special = 'leader', key = 't', action = wezterm.action.SpawnTab('CurrentPaneDomain') },
  { special = 'leader', key = 'T', action = wezterm.action.SpawnTab('DefaultDomain') },
  { special = 'leader', key = 'u', action = wezterm.action.CharSelect },
  { special = 'leader', key = 'w', action = wezterm.action.CloseCurrentTab { confirm = true } },
  { special = 'leader', key = 'x', action = wezterm.action.CloseCurrentPane { confirm = true } },
  { special = 'leader', key = 'z', action = wezterm.action.TogglePaneZoomState },
  { special = 'leader', key = '-', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
  { special = 'leader', key = '|', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { special = 'leader', key = '.', action = wezterm.action.SplitPane { direction = 'Down', size = { Cells = 4 }, top_level = true } },
  { special = 'leader', key = '<', action = wezterm.action.MoveTabRelative(-1) },
  { special = 'leader', key = '>', action = wezterm.action.MoveTabRelative(1) },

  {
    special = 'leader',
    key = 'o',
    action = wezterm.action.QuickSelectArgs {
      label = 'Open URL',
      patterns = { 'https?://\\S+' },
      action = wezterm.action_callback(function(window, pane)
        local url = window:get_selection_text_for_pane(pane)
        wezterm.open_with(url)
      end)
    },
  },
  {
    special = 'leader',
    key = 'h',
    action = wezterm.action.SplitPane {
      command = { args = { 'key-explorer' } },
      direction = 'Up',
      top_level = true,
      size = { Percent = 97 },
    }
  },
  {
    special = 'leader',
    key = 'c',
    action = wezterm.action_callback(function(window, pane)
      local workspace = pane:tab():window():get_workspace()
      local cwd = wezterm.GLOBAL.sessions[workspace]

      window:perform_action(wezterm.action.SpawnCommandInNewTab { cwd = cwd }, pane)
    end),
  },
  {
    special = 'leader',
    key = 'd',
    action = wezterm.action_callback(function(window, pane)
      if window:active_workspace() ~= 'default' then
        window:perform_action(wezterm.action.SwitchToWorkspace { name = 'default' }, pane)
      end
    end)
  },

  { special = 'leader', mods = 'CTRL', key = 'a', action = wezterm.action.ActivatePaneDirection('Next') },
  { special = 'leader', mods = 'CTRL', key = 'd', action = wezterm.action.ActivateCopyMode },
  { special = 'leader', mods = 'CTRL', key = 'j', action = wezterm.action.ShowLauncherArgs { flags = 'WORKSPACES' } },
  { special = 'leader', mods = 'CTRL', key = 'o', action = wezterm.action.RotatePanes('Clockwise') },

  { special = 'leader', key = '1', action = wezterm.action.ActivateTab(0) },
  { special = 'leader', key = '2', action = wezterm.action.ActivateTab(1) },
  { special = 'leader', key = '3', action = wezterm.action.ActivateTab(2) },
  { special = 'leader', key = '4', action = wezterm.action.ActivateTab(3) },
  { special = 'leader', key = '5', action = wezterm.action.ActivateTab(4) },
  { special = 'leader', key = '6', action = wezterm.action.ActivateTab(5) },
  { special = 'leader', key = '7', action = wezterm.action.ActivateTab(6) },
  { special = 'leader', key = '8', action = wezterm.action.ActivateTab(7) },
  { special = 'leader', key = '9', action = wezterm.action.ActivateTab(8) },

  { special = 'tmux', key = 'n', mods = 'MOD', action = wezterm.action.SpawnTab('CurrentPaneDomain') },
  { special = 'tmux', key = 'c', mods = 'MOD', action = wezterm.action.CopyTo('Clipboard') },
  { special = 'tmux', key = 'v', mods = 'MOD', action = wezterm.action.PasteFrom('Clipboard') },

  { special = 'tmux', key = '1', mods = 'MOD', action = wezterm.action.ActivateTab(0) },
  { special = 'tmux', key = '2', mods = 'MOD', action = wezterm.action.ActivateTab(1) },
  { special = 'tmux', key = '3', mods = 'MOD', action = wezterm.action.ActivateTab(2) },
  { special = 'tmux', key = '4', mods = 'MOD', action = wezterm.action.ActivateTab(3) },
  { special = 'tmux', key = '5', mods = 'MOD', action = wezterm.action.ActivateTab(4) },
  { special = 'tmux', key = '6', mods = 'MOD', action = wezterm.action.ActivateTab(5) },
  { special = 'tmux', key = '7', mods = 'MOD', action = wezterm.action.ActivateTab(6) },
  { special = 'tmux', key = '8', mods = 'MOD', action = wezterm.action.ActivateTab(7) },
  { special = 'tmux', key = '9', mods = 'MOD', action = wezterm.action.ActivateTab(8) },
}

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
  leader = { key = 'q', mods = 'CTRL', timeout_millisecons = 3000 },
  keys = mappings.keys,
  key_tables = {
    tmux_like = mappings.key_tables.tmux_like,
  },
  hide_tab_bar_if_only_one_tab = true,
  use_fancy_tab_bar = false,
  show_new_tab_button_in_tab_bar = false,
  window_padding = appearance.window_padding,
  adjust_window_size_when_changing_font_size = false,
  color_schemes = {
    default = {
      background = '#191926',
    },
    workspace = {
      background = '#000000',
      tab_bar = {
        background = '#222222',
        active_tab = {
          bg_color = 'rgb(0,175,255)',
          fg_color = 'rgb(28,28,28)',
        },
        inactive_tab = {
          bg_color = '#222222',
          fg_color = '#cccccc',
        },
      },
    },
    tmux_in_default = {
      background = '#000000',
    },
  },
  colors = {
    cursor_bg = '#ffffff',
    cursor_fg = '#000000',
    cursor_border = '#ffffff',
    visual_bell = '#707070',
    split = '#44ff44',
  },
}
