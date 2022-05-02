function! s:set_quickfix(value, title, context) abort
  let oldfmt = &errorformat
  set errorformat=%f:%l:%c\ %m,%f:%l\ %m,%-G#\ stalker\ quickfix\ %m
  cexpr a:value
  call setqflist([], 'a', {'title': a:title, 'context': a:context})
  let &errorformat = oldfmt
endfunction

function! s:load_quickfix() abort
  let output = system('~/.scripts/mire stalker quickfix')
  let id = matchstr(split(output, "\n")[0], '# stalker quickfix \zs\S\+')
  call s:set_quickfix(output, 'stalker quickfix', {'id': id})
endfunction

function! s:load_failure() abort
  let data = getqflist({'idx': 0, 'items': 1, 'context': 1})
  let index = get(data, 'idx', 0)

  if type(data.context) != v:t_dict || ! has_key(data.context, 'id')
    echohl WarningMsg
    echomsg "Current quickfix is not from stalker"
    echohl None
    return
  elseif data.context.id == 'stalker-failure'
    echohl WarningMsg
    echomsg "Already looking at a failure. Go back with :colder if you want to visit another"
    echohl None
    return
  elseif index == 0
    echohl WarningMsg
    echomsg "No currently selected index in quickfix (somehow)"
    echohl None
    return
  endif

  let title = data.items[index - 1].text
  let id = data.context.id
  let output = system(printf('~/.scripts/mire stalker failure %s %s', id, index - 1))
  call s:set_quickfix(output, 'stalker failure', {'id': 'stalker-failure'})
endfunction

function! s:load_stacktrace()
  let output = system('~/.scripts/stalker stacktrace')
  call s:set_quickfix(output, 'stalker stacktrace', {})
endfunction

command! -nargs=0 StalkerQuickfix call s:load_quickfix()
command! -nargs=0 StalkerFailure call s:load_failure()
command! -nargs=0 StalkerStacktrace call s:load_stacktrace()

map <Leader>q <Cmd>StalkerQuickfix<CR>
map <Leader>Q <Cmd>StalkerFailure<CR>
