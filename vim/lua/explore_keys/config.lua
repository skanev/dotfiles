local layout = require('explore_keys.layout')
local Modifier = require('explore_keys.modifier')

---@class ek.Configuration
---@field ignored_mappings string[]
---@field modifiers ek.Modifier[]

---@type ek.Configuration
local configuration = {
  ignored_mappings = {},
  modifiers = {
    Modifier:new {
      name = 'None',
      keys = layout.all_keys,
      image = layout.images.double_narrow,
      fn = function(key) return key end,
    },
    Modifier:new {
      name = 'Control',
      keys = layout.modifiable_keys,
      image = layout.images.single_narrow,
      fn = function(key) return string.format("<C-%s>", key:upper()) end,
    },
    Modifier:new {
      name = 'Meta',
      keys = layout.modifiable_keys,
      image = layout.images.single_narrow,
      fn = function(key) return string.format("<D-%s>", key:lower()) end,
    }
  }
}

local function configure(opts)
  opts = opts or {}

  if opts.ignored_mappings then
    configuration.ignored_mappings = opts.ignored_mappings
  end
end

return {
  configuration = configuration,
  configure = configure,
}
