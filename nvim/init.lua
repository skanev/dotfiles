--TODO Is this necessary or can it be removed?
vim.g.dotfiles_dir = vim.fn.expand('~/code/personal/dotfiles')

vim.opt.runtimepath:prepend('~/.vim/after')
vim.opt.runtimepath:prepend('~/.vim')

vim.o.packpath = vim.o.runtimepath

local function best_match(pattern)
  return vim.fn.reverse(vim.fn.sort(vim.fn.glob(pattern, true, true)))[1]
end

vim.g.python_host_prog = best_match('~/.pyenv/versions/*/envs/neovim-python2/bin/python')
vim.g.python3_host_prog = best_match('~/.pyenv/versions/*/envs/neovim-python3/bin/python')
vim.g.ruby_host_prog = best_match('~/.rbenv/versions/*/bin/neovim-ruby-host')

vim.g.firenvim_config = { globalSettings = { takeover = 'never' }, localSettings = { [".*"] = { takeover = 'never' } } }

vim.cmd [[source ~/.vimrc]]
