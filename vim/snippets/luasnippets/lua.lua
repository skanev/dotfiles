local ls = require("luasnip")
local s = ls.s
local i = ls.i
--local t = ls.t

local d = ls.dynamic_node
--local c = ls.choice_node
--local f = ls.function_node
local sn = ls.snippet_node

local fmt = require("luasnip.extras.fmt").fmt
--local rep = require("luasnip.extras").rep

return {
  s('lreq', fmt([[local {} = require('{}')]], {
    d(2, function(args)
      local parts = vim.split(args[1][1], '.', { plain = true })
      local name = parts[#parts]
      if name == '' then
        name = 'name'
      end
      return sn(nil, i(1, name))
    end, { 1 }),
    i(1, 'package')
  })),
  s('unload', fmt([[package.loaded['{}'] = nil]], {
    d(1, function()
      local name = vim.fn.matchstr(vim.fn.expand('%'), [[\<lua/\zs.*\ze\.lua]])

      if name == '' then
        name = 'package'
      end

      return sn(nil, i(1, name))
    end)
  })),
}
