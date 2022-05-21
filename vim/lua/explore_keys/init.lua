local configuration = require('explore_keys.config')
local explorer = require('explore_keys.explorer')

vim.cmd [[
  highlight      KeyBrowserBackground guifg=#505050
  highlight      KeyBrowserBorder     guifg=#505050

  highlight link KeyBrowserCurrentInput Constant
  highlight link KeyBrowserAccent       Todo
  highlight link KeyBrowserText         Normal

  highlight link KeyBrowserActionSpecial  SpecialKey
  highlight link KeyBrowserActionNormal   Normal
  highlight link KeyBrowserActionMappings Number

  highlight      KeyBrowserKeyDefault guifg=#aaaaaa
  highlight      KeyBrowserKeyGlobal  guifg=#66ffff
  highlight      KeyBrowserKeyBuffer  guifg=#66ff33
  highlight      KeyBrowserKeyMixed   guifg=#66ff88
  highlight link KeyBrowserKeyError   ErrorMsg
]]

local function explore(seqs)
  local explainer = explorer.Explorer:new()

  explainer:obtain_mappings(0)
  explainer:open_window()

  --- TODO This handles both (1) being given an initial input and (2) being given command arguments; should split
  if seqs and type(seqs) == 'string' then
    explainer:feed(seqs)
  end
  explainer:render()
end

--- for development purposes
local function rerun()
  local current = configuration.configuration

  for key, _ in pairs(package.loaded) do
    if key:match('^explore_keys') then
      package.loaded[key] = nil
    end
  end

  require('explore_keys').setup(current)
  require('explore_keys').explore()
end

local function setup(opts)
  configuration.configure(opts)

  vim.api.nvim_create_user_command('ExploreKeys', explore, {})
  vim.api.nvim_create_user_command('RerunExploreKeys', rerun, {})
end

return {
  setup = setup,
  explore = explore,
  rerun = rerun,
}
