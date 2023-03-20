local ls = require("luasnip")
local s = ls.s
local i = ls.i
local t = ls.t

local d = ls.dynamic_node
--local c = ls.choice_node
--local f = ls.function_node
local sn = ls.snippet_node
--local isn = ls.indent_snippet_node

--local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
--local rep = require("luasnip.extras").rep
local extras = require("luasnip.extras")

--local ts = require('vim.treesitter')
local tsu = require 'nvim-treesitter.ts_utils'
local tsq = require('vim.treesitter.query')

local function find_previous_line(pattern)
  local result = vim.fn.search(pattern, 'bnW')

  if result ~= 0 then
    return vim.fn.getline(result)
  else
    return nil
  end
end

local function find_previous_match(line_pattern, group_pattern)
  local line = find_previous_line(line_pattern) or ''
  local match = vim.fn.matchstr(line, group_pattern)

  return match ~= '' and match or nil
end

local function find_parent(node, types)
  while node do
    local node_type = node:type()

    for _, type in ipairs(types) do
      if type == node_type then
        return node
      end
    end

    node = node:parent()
  end

  return nil
end

local function find_matches(container, query, name)
  local result = {}

  for id, node in query:iter_captures(container, 0, 0, -1) do
    if query.captures[id] == name then
      table.insert(result, tsq.get_node_text(node, 0))
    end
  end

  return result
end

local function return_types_query(root)
  return tsq.parse_query('go', string.format([[
    (%s result: [
      (type_identifier) @type
      (parameter_list (parameter_declaration type: (_) @type))
    ])
  ]], root))
end

local builtin_types_defaults = {
  bool = 'false',
  string = '""',
  int = '0',
  int8 = '0',
  int16 = '0',
  int32 = '0',
  int64 = '0',
  uint = '0',
  uint8 = '0',
  uint16 = '0',
  uint32 = '0',
  uint64 = '0',
  uintptr = '0',
  byte = '0',
  rune = "' '",
  float32 = '0',
  float64 = '0',
  complex64 = '0',
  complex128 = '0',
  error = 'err',
}

local function default_value(type)
  return builtin_types_defaults[type] or 'nil'
end

local queries = {
  method_declaration = return_types_query('method_declaration'),
  function_declaration = return_types_query('function_declaration'),
  func_literal = return_types_query('func_literal'),
}

return {
  s('ret', {
    d(1, function()
      local definition = find_parent(tsu.get_node_at_cursor(0), { 'function_declaration', 'method_declaration', 'func_literal' })

      if not definition then return t('return ') end

      local matches = find_matches(definition, queries[definition:type()], 'type')

      local result = {}
      table.insert(result, t('return '))

      for index, type in ipairs(matches) do
        if index ~= 1 then table.insert(result, t(', ')) end
        table.insert(result, i(index, default_value(type)))
      end

      return sn(nil, result)
    end),
    i(0)
  }),
  s('meth', {
    d(1, function()
      local text = find_previous_match(
        [[^func\s\+]],
        [[^func\s\+(\zs\S\+\s\+\S\+\ze)]]
      )

      local receiver = 'received'
      local type = 'type'

      if text then
        local parts = vim.split(text, ' ', { plain = true })
        receiver = parts[1]
        type = parts[2]
      end

      return sn(nil, fmta([[func (<> <>) <>(<>) <><>{]], {
        i(1, receiver),
        i(2, type),
        i(3, 'name'),
        i(4),
        i(5),
        extras.nonempty(4, ' ', '')
      }))
    end, {}),
    t { "", "\t" },
    i(0),
    t { "", "}" },
  }),
}
