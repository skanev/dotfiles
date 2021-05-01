if exists('b:did_myftplugin') | finish | endif
let b:did_myftplugin = 1

set softtabstop=2 tabstop=2 shiftwidth=2 expandtab

vmap <buffer> Q :<C-u>call <SID>execute_in_tmux()<CR><CR>
nmap <buffer> Q :!tmux source %<CR>

function! s:execute_in_tmux()
  let name = tempname()
  exec ":'<,'>write" . name
  exec "!tmux source " . name
endfunction
