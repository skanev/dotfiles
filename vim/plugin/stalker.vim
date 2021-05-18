function! s:LoadRspec()
  let oldfmt = &errorformat
  set errorformat=%f:%l\ \#\ %m
  cexpr system('~/.scripts/stalker poke')
  let &errorformat = oldfmt
endfunction

map <Leader>q <Cmd>call <SID>LoadRspec()<CR>
