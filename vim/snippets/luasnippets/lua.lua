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
