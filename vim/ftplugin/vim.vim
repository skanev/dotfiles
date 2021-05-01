if exists('b:did_myftplugin') | finish | endif
let b:did_myftplugin = 1

set tabstop=2 softtabstop=2 shiftwidth=2 expandtab

function! s:ExecuteSelectionInVim()
  let name = tempname()
  silent exec ":'<,'>write" . name
  silent exec "source " . name
  echomsg "Executed selection"
endfunction

nmap <buffer> Q :source %<CR>
vmap <buffer> Q :<C-U>call <SID>ExecuteSelectionInVim()<CR>
