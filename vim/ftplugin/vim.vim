if exists('b:did_myftplugin') | finish | endif
let b:did_myftplugin = 1

set tabstop=2 softtabstop=2 shiftwidth=2 expandtab

nmap <buffer> Q :source %<CR>
vmap <buffer> Q :<C-U>call <SID>execute_selection()<CR>
nmap <buffer> <Leader>e <Cmd>execute! getline('.')<CR>

command! -buffer Switch call s:extended_switch()

let b:installed_switch = 0
let s:vim_options = []

function! s:execute_selection()
  let name = tempname()
  silent exec ":'<,'>write " . name
  silent exec "source " . name
  echomsg "Executed selection"
endfunction

function! s:extended_switch()
  if !b:installed_switch
    let b:installed_switch = 1

    if empty(s:vim_options)
      let s:vim_options = s:read_vim_options()
    endif

    let b:switch_custom_definitions = []

    for variants in s:vim_options
      if len(variants) == 1
        continue
      endif

      call add(b:switch_custom_definitions, switch#Words(variants))
      call add(b:switch_custom_definitions, switch#Words(map(copy(variants), "'no' . v:val")))
    endfor
  endif

  call switch#Switch()
endfunction

function s:read_vim_options()
  let files = split(&runtimepath, ',')
  call map(files, "v:val . '/doc/quickref.txt'")
  call filter(files, "filereadable(v:val)")

  let lines = readfile(get(files, 0))

  let i = 0

  while lines[i] !~ '\*option-list\*$' && i < len(lines)
    let i += 1
  endwhile

  let words = []

  while lines[i] !~ '^----------' && i < len(lines)
    let groups = matchlist(lines[i], '''\(\k\+\)''\s\+\%(''\(\k\+\)''\s\+\)\=\(.*\)')
    let i += 1

    if !len(groups) | continue | endif

    let variants = [groups[1]]

    if groups[2] != ''
      call add(variants, groups[2])
    endif

    call add(words, variants)
  endwhile

  return words
endfunction
