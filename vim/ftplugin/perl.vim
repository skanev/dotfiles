if (exists("b:did_skanev_ftplugin"))
  finish
endif
let b:did_skanev_ftplugin = 1

function! s:ShowHelp()
  let word = expand('<cword>')

  echo word

  if 'a' <= word && 'z' <= word
    exec "terminal ++close ++shell perldoc -o term -f " . word . ' || read -q'
  else
    exec "terminal ++close ++shell perldoc -o term " . word . ' || read -q'
  endif
endfunction

imap <buffer> <C-l> <Space>=><Space>
imap <buffer> <C-j> ->
nmap <buffer> K :call <SID>ShowHelp()<CR>

" TODO: The path below should not be hardcoded
setlocal path+=~/code/personal/dotfiles/src/perl/
setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
