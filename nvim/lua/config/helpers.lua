local env = require('config.env')
local M = {}

function M.mapping(lhs)
  lhs = lhs:gsub('{}', env.meta_key, 1)

  if env.app == 'nvim' and not env.tmux then
    lhs = lhs:gsub("<S%-F(%d+)>", function(n) return "<F" .. (tonumber(n) + 12) .. ">" end)
  end

  return lhs
end

function M.mapkey(mode, lhs, rhs, opts)
  lhs = M.mapping(lhs)

  vim.keymap.set(mode, lhs, rhs, opts)
end

return M
