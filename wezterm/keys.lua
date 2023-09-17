local wezterm = require('wezterm')
local environment = require('environment')
local tmux = require('tmux')

local all_characters = [[`1234567890-=qwertyuiop[]\asdfghjkl;'zxcvbnm,./]]
local characters = {}

for i = 1, #all_characters do
  table.insert(characters, all_characters:sub(i, i))
end

local function mappings(maps)
  local keys = {}
  local tmux_like = {}
  local seen = {}
  local mod_key = environment.mod

  -- Define all keys and track which are defined
  for _, mapping in ipairs(maps) do
    if mapping.special == 'leader' then
      -- insert leader mapping
      local leader_mod

      if mapping.mods then
        leader_mod = 'LEADER|' .. mapping.mods
      else
        leader_mod = 'LEADER'
      end

      table.insert(keys, {
        key = mapping.key,
        mods = leader_mod,
        action = mapping.action,
      })

      -- insert keytable mapping
      table.insert(tmux_like, {
        key = mapping.key,
        mods = mapping.mods,
        action = mapping.action,
      })

    elseif mapping.special == 'tabs' then
      local mods = mapping.mods and mapping.mods:gsub('MOD', mod_key)
      local tmux_mods = mapping.mods and mapping.mods:gsub('MOD', 'ALT')
      local key = mapping.key
      local action = mapping.action

      table.insert(keys, {
        key = key,
        mods = mods,
        action = wezterm.action_callback(function (window, pane)
          local process_name = pane:get_foreground_process_info() and pane:get_foreground_process_info().name
          local tabbed_vim = false

          if process_name == 'nvim' or process_name == 'vim' then
            local lines = pane:get_lines_as_text()
            local position = lines:find(".\n")

            -- if tabs are open, top row would end on X
            tabbed_vim = (lines:sub(position, position) == "X")
          end

          if tmux.is_running_tmux(pane) or tabbed_vim then
            window:perform_action(wezterm.action.SendKey { key = key, mods = tmux_mods }, pane)
          else
            window:perform_action(action, pane)
          end
        end)
      })

      seen[mods .. " " .. key:lower()] = true

    elseif mapping.special == 'tmux' then
      local mods = mapping.mods and mapping.mods:gsub('MOD', mod_key)
      local tmux_mods = mapping.mods and mapping.mods:gsub('MOD', 'ALT')
      local key = mapping.key
      local action = mapping.action

      table.insert(keys, {
        key = key,
        mods = mods,
        action = wezterm.action_callback(function (window, pane)
          if tmux.is_running_tmux(pane) then
            window:perform_action(wezterm.action.SendKey { key = key, mods = tmux_mods }, pane)
          else
            window:perform_action(action, pane)
          end
        end)
      })

      seen[mods .. " " .. key:lower()] = true

    elseif mapping.special == nil then
      mapping.mods = mapping.mods and mapping.mods:gsub('MOD', mod_key)
      table.insert(keys, mapping)

      seen[(mapping.mods or "").. " " .. mapping.key:lower()] = true
    end
  end

  -- Make CMD behave like ALT on macOS
  if mod_key == 'CMD' then
    for _, key in ipairs(characters) do
      for _, mods in ipairs({ 'CMD', 'CMD|SHIFT' }) do
        local combo = mods .. ' ' .. key

        if not seen[combo] then
          seen[combo] = true

          table.insert(keys, {
            key = key,
            mods = mods,
            action = wezterm.action.SendKey { key = key, mods = mods:gsub('CMD', 'ALT') },
          })
        end
      end
    end
  end

  return {
    keys = keys,
    key_tables = {
      tmux_like = tmux_like
    }
  }
end

return {
  keys = mappings
}
