local env = require('config.env')
local M = {}

function M.mapkey(mode, lhs, rhs, opts)
  lhs = lhs:gsub('{}', env.meta_key, 1)

  if env.app == 'nvim' then
    lhs = lhs:gsub("<S%-F(%d+)>", function(n) return "<F" .. (tonumber(n) + 12) .. ">" end)
  end

  vim.keymap.set(mode, lhs, rhs, opts)
end

return M
