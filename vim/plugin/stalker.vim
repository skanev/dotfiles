function! s:LoadRspec()
  let oldfmt = &errorformat
  set errorformat=%f:%l\ \#\ %m
  cexpr system('~/.scripts/stalker poke rspec')
  let &errorformat = oldfmt
endfunction

map <Leader>q <Cmd>call <SID>LoadRspec()<CR>
map [g <Cmd>colder<CR>
map ]g <Cmd>cnewer<CR>
map <Leader>g <Cmd>copen<CR>
