function! s#system(command)
  let oldshell = &shell
  set shell=/bin/bash
  let result = system(a:command)
  let &shell=oldshell
  return result
endfunction
