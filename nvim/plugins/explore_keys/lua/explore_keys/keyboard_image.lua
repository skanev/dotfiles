local layout = require('explore_keys.layout')

---@class ek.KeyboardImage
---@field image string
---@field keys_shown table<string, boolean>
---@field key_positions table<string, { row: number, col: number }>
---@field special_positions table<string, { row: number, col: number }>
local KeyboardImage = {}

---@param image string
---@return ek.KeyboardImage
function KeyboardImage:new(image)
  self.__index = self

  local instance = {
    image = image,
    keys_shown = {},
    key_positions = {},
    special_positions = {},
  }

  for row, line in pairs(vim.split(instance.image, "\n", {})) do
    for _, name in ipairs(layout.named_keys) do
      local col =  line:find(name, 1, true)
      if col then
        instance.special_positions[name] = { row = row, col = col }
      end
    end
  end

  local stripped = instance.image:gsub('%w%w%w+', function(s) return string.rep(' ', #s) end)
  stripped = stripped:gsub(' fn ', '    ')

  local drawable = {}
  for _, char in ipairs(layout.all_keys) do
    drawable[char] = true
  end

  for row, line in ipairs(vim.split(stripped, "\n", {})) do
    local init = 1

    while init ~= nil do
      local from, to = line:find('%S', init)

      if from and to then
        local char = line:sub(from, to)
        if drawable[char] then
          instance.key_positions[char] = { row = row, col = from }
        end
        init = to + 1
      else
        break
      end
    end
  end

  return setmetatable(instance, self)
end

---@return string[]
function KeyboardImage:available_keys()
  return vim.tbl_keys(self.key_positions)
end

return KeyboardImage
