if (exists("b:did_skanev_ftplugin"))
  finish
endif
let b:did_skanev_ftplugin = 1

function! s:AbsorbSnippets()
  execute "read !~/.vim/scripts/absorb-snippets.pl " . expand('%:t:r')
endfunction

setlocal list tabstop=4 softtabstop=4
command! -buffer AbsorbSnippets call <SID>AbsorbSnippets()
