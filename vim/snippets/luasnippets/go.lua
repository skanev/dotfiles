local ls = require("luasnip")
local s = ls.s
local i = ls.i
local t = ls.t

local d = ls.dynamic_node
local c = ls.choice_node
local f = ls.function_node
local sn = ls.snippet_node
local isn = ls.indent_snippet_node

local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep
local extras = require("luasnip.extras")

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

return {
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

      return sn(nil, fmta([[func (<> <>) <>() <><>{]], {
        i(1, receiver),
        i(2, type),
        i(3, 'name'),
        i(4),
        extras.nonempty(4, ' ', '')
      }))
    end, {}),
    t { "", "\t" },
    i(0),
    t { "", "}" },
  }),
}
