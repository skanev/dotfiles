function! s:MapMeta(args)
  let key = strpart(a:args, 0, 1)
  let mapping = strpart(a:args, 2)
  if has('gui_macvim')
    exec "map <D-" . key . "> " . mapping
  else
    exec "map <M-" . key . "> " . mapping
  end
endfunction

command! -nargs=1 MapMeta call s:MapMeta(<f-args>)
