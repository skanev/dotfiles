function! MapMeta(mode, args, options)
  let key = strpart(a:args, 0, 1)
  let mapping = strpart(a:args, 2)
  if has('gui_macvim')
    let modifier = 'D'
  else
    let modifier = 'M'
  endif

  exec a:mode . "map " . a:options . " <" . modifier . "-" . key . "> " . mapping
endfunction

command! -nargs=1 MapMeta call MapMeta('n', <f-args>, '')
command! -nargs=1 VMapMeta call MapMeta('v', <f-args>, '')
