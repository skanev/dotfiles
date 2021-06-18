function! s:load_quickfix()
  let oldfmt = &errorformat
  set errorformat=%f:%l:%c\ %m,%f:%l\ %m,
  cexpr system('~/.scripts/stalker poke quickfix')
  let &errorformat = oldfmt
endfunction

map <Leader>q <Cmd>call <SID>load_quickfix()<CR>
