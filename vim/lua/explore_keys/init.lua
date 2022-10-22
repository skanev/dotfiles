local configuration = require('explore_keys.config')
local explorer = require('explore_keys.explorer')

vim.cmd [[
  highlight      KeyBrowserBackground guifg=#505050
  highlight      KeyBrowserBorder     guifg=#505050

  highlight link KeyBrowserCurrentInput Constant
  highlight link KeyBrowserAccent       Todo
  highlight link KeyBrowserText         Delimiter

  highlight link KeyBrowserActionSpecial  SpecialKey
  highlight link KeyBrowserActionNormal   Delimiter
  highlight link KeyBrowserActionMappings Number

  highlight      KeyBrowserKeyDefault guifg=#aaaaaa
  highlight      KeyBrowserKeyGlobal  guifg=#66ffff
  highlight      KeyBrowserKeyBuffer  guifg=#66ff33
  highlight      KeyBrowserKeyMixed   guifg=#66ff88
  highlight link KeyBrowserKeyError   ErrorMsg
]]

local function explore(opts)
  opts = opts or {}
  local mode = opts.mode or 'n'
  local explainer = explorer.Explorer:new()

  explainer:obtain_mappings(0, mode)
  explainer:open_window()

  if opts.prefix then
    explainer:feed(opts.prefix)
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

local function setup(config)
  local modes = { normal = 'n', insert = 'i' }

  configuration.configure(config)

  vim.api.nvim_create_user_command('RerunExploreKeys', rerun, {})

  vim.api.nvim_create_user_command(
    'ExploreKeys',
    function(opts)
      local mode = opts.args
      if mode == '' then
        mode = 'normal'
      end

      if modes[mode] == nil then
        vim.api.nvim_err_writeln("Unrecognized mode: " .. mode)

      else
        explore { mode = modes[mode], prefix = '' }
      end
    end,
    {
      nargs = '?',
      complete = function(_, line)
        local options = vim.tbl_keys(modes)
        local parts = vim.split(line, '%s+')

        if #parts == 1 then
          return options
        elseif #parts == 2 then
          return vim.tbl_filter(function(val) return vim.startswith(val, parts[2]) end, options)
        end
      end,
    }
  )
end

return {
  setup = setup,
  explore = explore,
  rerun = rerun,
}
