if (exists("b:did_skanev_ftplugin"))
  finish
endif
let b:did_skanev_ftplugin = 1

let s:syntax = matchstr(getline('2'), 'syntax: \zs.*\ze')

if s:syntax != ''
  let &syntax = s:syntax
endif

function! s:InsertOctothorpe()
  let previous_line = getline(line('.') - 1)

  if previous_line == ''
    let previous_line = getline(line('.') - 2)
  endif

  let [_, start, _] = matchstrpos(previous_line, '  \zs#', 0)
  let pos = col('.')
  let previous_char = getline('.')[pos - 2]

  if s:syntax != 'zsh' || start == -1 || pos > start || previous_char != ' '
    return '#'
  else
    return repeat(' ', start - pos + 1) . '#'
  endif
endf

inoremap <buffer> <expr> # <SID>InsertOctothorpe()
