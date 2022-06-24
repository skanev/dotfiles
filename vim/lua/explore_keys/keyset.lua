local Path = require("plenary.path")
local drawing = require('explore_keys.drawing')
local inventory = require('explore_keys.inventory')

---@param func_ref funcref
---@return string | nil
---@return { file: string, line: number } | nil
local function infer_function_description_and_location(func_ref)
  local info = debug.getinfo(func_ref)

  local filename = info.source:gsub("@", "")
  local line_number = info.linedefined
  local path = Path:new(filename)
  if not path:exists() then
    return nil
  end

  local line = path:readlines()[line_number]

  if line == nil then
    return nil
  end

  local matchers = {
    { pattern = 'vim%.keymap%.set.*function%([^%)]*%)%s*(.*)%s*end', defining = true },
    { pattern = 'function%([^%)]*%)%s*(.*)%s*end', defining = true },
    { pattern = '^%s*local function ([^%(]+)%(', defining = false },
    { pattern = '^%s*function ([^%(]+)%(', defining = false },
  }

  ---@cast matchers { pattern: string, defining: boolean }[]
  for _, matcher in ipairs(matchers) do
    local match = line:match(matcher.pattern)
    if match and matcher.defining then
      return match, { file = filename, line = line_number }
    elseif match then
      return match
    end
  end

  return nil
end

---@return table<string, { file: string, line: number }>
local function find_mapping_locations()
  local result = {
    buffer = {},
    global = {},
  }

  vim.cmd [[
    let saved_p = @p

    try
      redir @p
      let @p = ""
      execute "silent verbose nmap"
      redir END

      let g:explore_keys_output = @p
    finally
      let @p = saved_p
    endtry
  ]]
  local output = vim.g.explore_keys_output

  vim.cmd [[unlet g:explore_keys_output]]

  local lines = vim.split(output, "\n", true)
  local i = 1
  while i < #lines do
    if lines[i] == "" then
      i = i + 1
      goto continue
    end

    local buffer = false
    local lhs = lines[i]:sub(4, #lines[i]):match('^%S+')

    if not lhs then
      i = i + 1
      goto continue
    end

    local prefix = lines[i]:sub(4 + #lhs, #lines[i]):match('^%s+(...)')
    if prefix and prefix:match('@', 1, false) then
      buffer = true
    end

    i = i + 1

    if lhs then
      if lines[i] and lines[i]:match('^         ') then
        i = i + 1
      end

      if lines[i] and lines[i]:match("^\t") then
        local file, line = lines[i]:match("\tLast set from (%S+) line (%d+)")
        if file and line and file ~= 'Lua' then
          local location = { file = file, line = tonumber(line) }
          if buffer then
            result.buffer[lhs] = location
          else
            result.global[lhs] = location
          end
        end
        i = i + 1
      end
    end

    ::continue::
  end

  return result
end

---@param lhs string
---@return ek.RichText
local function format_rhs(lhs)
  local index = 1
  local result = {}

  local rules = {
    { "^:",            'KeyBrowserActionSpecial' },
    { '<[^ >]+>',      'KeyBrowserActionSpecial' },
  }

  while index <= #lhs do
    for _, rule in ipairs(rules) do
      local from, to = lhs:find(rule[1], index)

      if from and to then
        local prefix = lhs:sub(index, from - 1)

        if #prefix > 0 then
          table.insert(result, { prefix, 'KeyBrowserActionNormal' })
        end

        table.insert(result, { lhs:sub(from, to), rule[2] })

        index = to + 1

        goto continue
      end
    end

    table.insert(result, { lhs:sub(index, #lhs), 'KeyBrowserActionNormal' })
    index = #lhs + 1

    ::continue::
  end

  return drawing.rich_text(result)
end

---@alias ek.MappingScope "global" | "buffer" | "default"

---@class ek.Mapping
---@field lhs string
---@field rhs string | nil
---@field doc string | nil
---@field desc string | nil
---@field location { file: string, line: number } | nil
---@field lua_code_guess string | nil
---@field callback function | nil
---@field plug boolean
---@field noremap boolean
---@field scope ek.MappingScope
local Mapping = {}

function Mapping:new(options)
  local instance = options
  self.__index = self
  return setmetatable(instance, self)
end

function Mapping.from_entry(entry)
  local lhs = entry.lhs
  local plug = (lhs:match('^<Plug>') ~= nil)

  return Mapping:new {
    lhs = lhs,
    plug = plug,
    rhs = entry.rhs,
    desc = entry.desc,
    callback = entry.callback,
    noremap = (entry.noremap == 1),
    scope = (entry.buffer == 0 and 'global' or 'buffer')
  }
end

function Mapping:with_new_lhs(lhs)
  local new = vim.tbl_extend('force', self, { lhs = lhs })
  return Mapping:new(new)
end

function Mapping:with_new_lhs_rhs(lhs, rhs)
  local new = vim.tbl_extend('force', self, { lhs = lhs, rhs = rhs })
  return Mapping:new(new)
end

function Mapping:description()
  return self.rhs or (self.callback and '<lua func>') or self.doc or '???'
end

function Mapping:formatted_description()
  if self.desc or self.doc then
    return drawing.rich_text { { self.desc or self.doc, 'KeyBrowserText' } }
  else
    return self:formatted_definition()
  end
end

function Mapping:formatted_definition()
  if self.rhs then
    return drawing.rich_text(format_rhs(self.rhs))
  elseif self.callback and self.lua_code_guess then
    return drawing.rich_text { { string.format('<lua> %s', self.lua_code_guess), 'KeyBrowserText' } }
  elseif self.callback then
    return drawing.rich_text { { string.format('<luafunc>', self.lua_code_guess), 'KeyBrowserText' } }
  elseif self.doc then
    return drawing.rich_text { { 'built-in', 'KeyBrowserText' } }
  else
    return drawing.rich_text { '???' }
  end
end

---Look for mappings of prefixes of other mappings. That is, if you have:
---
---  map <Plug>(prefix)a something
---  map yo <Plug>(prefix)
---
---It behaves as if you actually had as well:
---
---  map yoa something
---
---Useful for unimpaired that does this kind of shenanigans.
--
---@param mappings table<string, ek.Mapping>
local function expand_plug_prefixes(mappings)
  local found = {}

  for _, mapping in pairs(mappings) do
    local matches = {}

    if mapping.rhs and vim.startswith(mapping.rhs, '<Plug>') and not mapping.noremap then
      for _, other in pairs(mappings) do
        if vim.startswith(other.lhs, mapping.rhs) and #other.lhs > #mapping.rhs then
          table.insert(matches, other)
        end
      end
    end

    for _, match in ipairs(matches) do
      local new_lhs = mapping.lhs .. match.lhs:sub(#mapping.rhs + 1, #match.lhs)
      local new_mapping = mapping:with_new_lhs_rhs(new_lhs, match.rhs)

      if mappings[new_lhs] == nil then
        found[new_lhs] = new_mapping
      end
    end
  end

  for lhs, mapping in pairs(found) do
    mappings[lhs] = mapping
  end
end


---Splits a mapping, returning the first seq and the tail
---@param lhs any
---@return string
---@return string
local function split_mapping(lhs)
  local from, to = vim.regex([[^\(<[^>]\+>\|.\)]]):match_str(lhs)

  if not from or not to then
    return lhs, ''
  end

  local seq = lhs:sub(from, to)
  local suffix = lhs:sub(to + 1, #lhs)

  return seq, suffix
end

---@class ek.Keyset.Continuation.Item
---@field tail string
---@field mapping ek.Mapping

---@class ek.Keyset.Continuation
---@field key string
---@field prefix string
---@field items ek.Keyset.Continuation.Item[]
local Continuation = {}

---@param attributes { key: string, tail: string, action: string }
---@return ek.Keyset.Continuation
function Continuation:new(attributes)
  local instance = attributes
  instance.items = {}
  self.__index = self
  return setmetatable(instance, self)
end

---@return any
function Continuation:formatted_description()
  if #self.items == 1 and self.items[1].tail == "" then
    return self.items[1].mapping:formatted_description()
  else
    local text = self.items == 1 and '(1 map)' or string.format('(%s maps)', #self.items)

    return drawing.rich_text {
      { '-> ', 'KeyBrowserText' },
      { text, 'KeyBrowserActionMappings' }
    }
  end
end

---@return ek.MappingScope
function Continuation:scope()
  local global_count = 0
  local buffer_count = 0
  local default_count = 0

  for _, item in ipairs(self.items) do
    if item.mapping.scope == 'buffer' then
      buffer_count = buffer_count + 1
    elseif item.mapping.scope == 'default' then
      default_count = default_count + 1
    elseif item.mapping.scope == 'global' then
      global_count = global_count + 1
    else
      error("Unknown scope for: " .. vim.inspect(item))
    end
  end

  if default_count == #self.items then return 'default'
  elseif buffer_count + default_count == #self.items then return 'buffer'
  elseif global_count + default_count == #self.items then return 'global'
  else return 'mixed'
  end
end

---@param tail string
---@param mapping ek.Mapping
function Continuation:add_item(tail, mapping)
  table.insert(self.items, { tail = tail, mapping = mapping })
end

---@class ek.Keyset
---@field mappings table<string, ek.Mapping>
---@field default_mappings table<string, ek.Mapping>
---@field global_mappings table<string, ek.Mapping>
---@field buffer_mappings table<string, ek.Mapping>
local Keyset = {}

---@param bufid buffer
---@param opts? { expand_plug_prefixes?: boolean, find_locations?: boolean, mode?: 'i' | 'n' }
---@return ek.Keyset
function Keyset.for_buffer(bufid, opts)
  opts = opts or {}
  local mode = opts.mode or 'n'
  local find_locations = opts.find_locations or false

  local keymaps = {
    { kind = 'global', mappings = vim.api.nvim_get_keymap(mode) },
    { kind = 'buffer', mappings = vim.api.nvim_buf_get_keymap(bufid, mode) },
  }

  local mappings = {
    default = {},
    global = {},
    buffer = {},
  }

  for lhs, doc in pairs(inventory.modes[mode]) do
    mappings.default[lhs] = Mapping:new {
      lhs = lhs,
      --action = doc,
      --rhs = doc,
      doc = doc,
      action = doc,
      plug = false,
      scope = 'default',
    }
  end

  local vimscript_locations = find_locations and find_mapping_locations() or {}

  for _, keymap in ipairs(keymaps) do
    for _, entry in ipairs(keymap.mappings) do
      local mapping = Mapping.from_entry(entry)
      mappings[keymap.kind][entry.lhs] = mapping

      if not find_locations then
      elseif mapping.rhs and mapping.scope == 'buffer' then
        mapping.location = vimscript_locations.buffer[mapping.lhs]
      elseif mapping.rhs and mapping.scope == 'global' then
        mapping.location = vimscript_locations.global[mapping.lhs]
      elseif mapping.callback then
        local name, location = infer_function_description_and_location(mapping.callback)
        mapping.lua_code_guess = name
        mapping.location = location
      end
    end

    if opts.expand_plug_prefixes then
      expand_plug_prefixes(mappings[keymap.kind])
    end
  end

  return Keyset:new {
    default = mappings.default,
    global = mappings.global,
    buffer = mappings.buffer,
  }
end

function Keyset:new(opts)
  opts = opts or {}

  local instance = {
    default_mappings = opts.default or {},
    global_mappings = opts.global or {},
    buffer_mappings = opts.buffer or {},
    mappings = {},
  }

  for _, set in ipairs({ instance.default_mappings, instance.global_mappings, instance.buffer_mappings }) do
    for lhs, mapping in pairs(set) do
      instance.mappings[lhs] = mapping
    end
  end

  self.__index = self
  return setmetatable(instance, self)
end

---@class ek.Keyset.Analysis
---@field terminated ek.Mapping | nil
---@field continuations table<string, ek.Keyset.Continuation>
---@field complete boolean

---@param prefix string
---@return ek.Keyset.Analysis
function Keyset:analyse(prefix)
  ---@type ek.Mapping[]
  local matching = {}

  for lhs, mapping in pairs(self.mappings) do
    if vim.startswith(lhs, prefix) then
      table.insert(matching, mapping)
    end
  end

  ---@type table<string, ek.Keyset.Continuation>
  local continuations = {}

  for _, mapping in ipairs(matching) do
    local lhs = mapping.lhs:sub(#prefix + 1, #mapping.lhs)

    if lhs ~= "" then
      local first, tail = split_mapping(lhs)
      continuations[first] = continuations[first] or Continuation:new { key = first, prefix = prefix, }
      continuations[first]:add_item(tail, mapping)
    end
  end

  local complete = (#matching == 1 and matching[1].lhs == prefix)

  return {
    complete = complete,
    terminated = self.mappings[prefix],
    continuations = continuations,
  }
end

---@param prefix string
function Keyset:has_mapping_prefix(prefix)
  for lhs, _ in pairs(self.mappings) do
    if vim.startswith(lhs, prefix) then
      return true
    end
  end

  return false
end

---@param lhs string
---@return boolean
function Keyset:has_mapping(lhs)
  return self.mappings[lhs] ~= nil
end

---@param lhs string
---@return { default: ek.Mapping|nil, global: ek.Mapping|nil, buffer: ek.Mapping|nil }
function Keyset:mappings_for(lhs)
  return {
    default = self.default_mappings[lhs],
    global = self.global_mappings[lhs],
    buffer = self.buffer_mappings[lhs],
  }
end

function Keyset:find_locations()
  local vim_locations = find_mapping_locations()

  for _, group in ipairs({ self.global_mappings, self.buffer_mappings }) do
    for _, mapping in pairs(group) do
      ---@cast mapping ek.Mapping
      if mapping.rhs and mapping.scope == 'buffer' then
        mapping.location = vim_locations.buffer[mapping.lhs]
      elseif mapping.rhs and mapping.scope == 'global' then
        mapping.location = vim_locations.global[mapping.lhs]
      elseif mapping.callback then
        local name, location = infer_function_description_and_location(mapping.callback)
        mapping.lua_code_guess = name
        mapping.location = location
      end
    end
  end
end

return {
  Keyset = Keyset,
  Mapping = Mapping,
  Continuation = Continuation,
  split_mapping = split_mapping,
}
