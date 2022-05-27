let g:dotfiles_dir = expand('<sfile>:p:h:h')

set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath

function! s:best_match(pattern)
  return get(reverse(sort(glob(a:pattern, 1, 1))), 0, "")
endfunction

let g:python_host_prog = s:best_match('~/.pyenv/versions/*/envs/neovim-python2/bin/python')
let g:python3_host_prog = s:best_match('~/.pyenv/versions/*/envs/neovim-python3/bin/python')
let g:ruby_host_prog = s:best_match('~/.rbenv/versions/*/bin/neovim-ruby-host')

source ~/.vimrc
