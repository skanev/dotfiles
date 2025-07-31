vim.g.dotfiles_dir = vim.fn.expand('~/code/personal/dotfiles')

if vim.env.NEWVIM == nil then
  vim.opt.runtimepath:prepend('~/.vim/after')
  vim.opt.runtimepath:prepend('~/.vim')
  vim.cmd "set runtimepath-=~/.config/nvim"
  vim.cmd "set runtimepath-=~/.config/nvim/after"

  vim.o.packpath = vim.o.runtimepath

  local function best_match(pattern)
    return vim.fn.reverse(vim.fn.sort(vim.fn.glob(pattern, true, true)))[1]
  end

  vim.g.python_host_prog = best_match('~/.pyenv/versions/*/envs/neovim-python2/bin/python')
  vim.g.python3_host_prog = best_match('~/.pyenv/versions/*/envs/neovim-python3/bin/python')
  vim.g.ruby_host_prog = best_match('~/.rbenv/versions/*/bin/neovim-ruby-host')

  vim.g.firenvim_config = { globalSettings = { takeover = 'never' }, localSettings = { [".*"] = { takeover = 'never' } } }

  vim.cmd [[source ~/.vimrc]]

  return
end

-- TODO: Some of those need to move somewhere
vim.g.have_nerd_font = true
vim.g.env = { meta_key = 'D' }

-- Must be set before lazy is loaded

vim.g.mapleader = ','
vim.g.maplocalleader = "\\"

require('config.env')
require('config.options')
require('config.mappings')
require('config.ft')

require('config.plugins.lazy')
require('config.plugins')
require('config.appearance').setup()

require('my.trailing_whitespace').setup()

vim.cmd "set runtimepath+=~/.config/nvim/plugins/explore_keys"

require('explore_keys').setup {
  ignored_mappings = {
    '<D-1>',
    '<D-2>',
    '<D-3>',
    '<D-4>',
    '<D-5>',
    '<D-6>',
    '<D-7>',
    '<D-8>',
    '<D-9>',
    '<C-Right>',
    '<C-Left>',
    '<S-Tab>',
  }
}

require('catppuccin').setup {
  flavour = 'macchiato',
  auto_integrations = true,
  dim_inactive = {
    enabled = true,
    shade = 'dark',
    percentage = 0.15,
  }
}

local vimStartup = vim.api.nvim_create_augroup('vimStartup', { clear = true })

vim.api.nvim_create_autocmd('BufReadPost', {
  group = vimStartup,
  callback = function()
    local type = vim.bo.filetype

    if type == 'commit' then return end

    local line = vim.api.nvim_buf_get_mark(0, '"')[1]

    if 0 < line and line <= vim.api.nvim_buf_line_count(0) then
      vim.cmd [[execute "normal! g`\""]]
    end
  end,
})
