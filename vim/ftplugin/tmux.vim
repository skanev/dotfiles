if exists('b:did_myftplugin') | finish | endif
let b:did_myftplugin = 1

function! s:ExecuteSelectionInTmux()
  let name = tempname()
  exec ":'<,'>write" . name
  exec "!tmux source " . name
endfunction


vmap <buffer> Q :<C-u>call <SID>ExecuteSelectionInTmux()<CR><CR>
nmap <buffer> Q :!tmux source %<CR>
