local M = {}

local group = vim.api.nvim_create_augroup('my_ftplugin', { clear = true })
local helpers = require('config.helpers')

vim.api.nvim_create_user_command("E", function()
  vim.cmd [[
    doautocmd <nomodeline> User ResetCustomizations
    edit
  ]]
end, {})

vim.api.nvim_create_user_command("MyFtplugin", function(opts)
  local name = nil

  if opts.args ~= "" then
    name = opts.args
  elseif vim.bo.filetype ~= "" then
    name = vim.bo.filetype
  else
    error('Current buffer has no filetype')
  end

  local filename = vim.fn.expand('~/.config/nvim/ftplugin/' .. name .. '.lua')

  vim.cmd('split ' .. filename)

  if vim.fn.filereadable(filename) == 0 then
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {
      "require('config.ft').once {}"
    })
  end

end, {
  nargs = '?',
  complete = function(arglead)
    local files = vim.fn.readdir(vim.fn.expand('~/.config/nvim/ftplugin'))
    local plugins = {}

    for _, file in ipairs(files) do
      local name = vim.fn.fnamemodify(file, ':t:r')
      if vim.startswith(name, arglead) then
        table.insert(plugins, name)
      end
    end

    return plugins
  end
})

vim.api.nvim_create_autocmd('User', {
  pattern = 'ResetCustomizations',
  group = group,
  callback = function()
    vim.b.did_my_ftplugin = nil
  end,
})

local function mapkey(mode, lhs, rhs, opts)
  opts = vim.tbl_extend('force', opts or {}, { buffer = true })

  helpers.mapkey(mode, lhs, rhs, opts)
end

local function wrap_table(specs)
  if type(specs) == 'table' and type(specs[1]) ~= 'table' then
    return { specs }
  else
    return specs
  end
end

local helper = {
  tabs = function(tabs)
    vim.bo.tabstop = tabs
    vim.bo.softtabstop = tabs
    vim.bo.shiftwidth = tabs
    vim.bo.expandtab = true
  end,

  runner = function(specs)
    specs = wrap_table(specs)

    local filename = vim.fn.expand('%')

    for _, spec in ipairs(specs) do
      if spec.when == nil or vim.fn.match(filename, spec.when) ~= -1 then
        require('my.runner').set_buf_runner(spec)
        break
      end
    end
  end,

  trailing_whitespace = function(value)
    require('my.trailing_whitespace').set_buffer(value)
  end,

  mappings = function(specs)
    specs = wrap_table(specs)

    local filename = vim.fn.expand('%')

    for _, spec in ipairs(specs) do
      if spec.when == nil or vim.fn.match(filename, spec.when) ~= -1 then
        local opts = {}

        for key, value in pairs(spec) do
          if type(key) == 'string' and key ~= 'when' then
            opts[key] = value
          end
        end

        mapkey(spec[1], spec[2], spec[3], opts)
      end
    end
  end,
}

function M.once(callback)
  if vim.b.did_my_ftplugin then
    return
  end

  if type(callback) == 'function' then
    callback()
  elseif type(callback) == 'table' then
    for key, value in pairs(callback) do
      helper[key](value)
    end
  else
    error("Unknown value for callback: " .. tostring(callback))
  end

  vim.b.did_my_ftplugin = true
end

return M
