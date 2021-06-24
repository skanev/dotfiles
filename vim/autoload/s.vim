function! s#system(command)
  let oldshell = &shell
  set shell=/bin/bash
  let result = system(a:command)
  let &shell=oldshell
  return result
endfunction

" Returns all the matches of a pattern in a given text
"
"   s#matches('(foo bar)', '\k\+') -> ['foo', 'bar']
"
function! s#matches(text, pattern) abort
  let results = []
  let pos = 0

  while v:true
    let [m, _, pos] = matchstrpos(a:text, a:pattern, pos)
    if pos == -1 | break | endif
    call add(results, m)
  endwhile

  return results
endfunction

" Flatmaps a list
"
"   [1, 2]->s#flatmap({_, k -> [k, k]}) -> [1, 1, 2, 2]
"
function! s#flatmap(list, function) abort
  let result = []
  for item in a:list
    call extend(result, a:function(item))
  endfor
  return result
endfunction

" Removes a list from another list
"
"   [1, 2, 3, 4]->s#without([1, 3]) -> [2, 4]
"
function! s#without(list, other) abort
  let elements = {}
  for e in a:other | let elements[e] = v:true | endfor
  return a:list->filter({_, e -> !elements->get(e) })
endfunction

function! s#starts_with(longer, shorter)
  return a:longer[0:len(a:shorter)-1] ==# a:shorter
endfunction

function! s#terminal(command, opts) abort
  if has('nvim')
    topleft new
    call termopen(a:command, {'on_exit': function('s:on_term_exit')})

    let mode = get(a:opts, 'mode', 'enter')
    if mode == 'enter'
      startinsert
    elseif mode == 'side'
      wincmd p
    end
  else
    echoerr "Not supported in VIM yet (can you imagine?)"
  end
endfunction

function! s:on_term_exit(job_id, code, event)
  if a:code == 0 | close | endif
endfunction

highlight SPopup guibg=#221f22

function! s:window_border(width, height)
  let lines = []

  call add(lines, '╭' . repeat('─', a:width) . '╮')
  for _ in range(a:height)
    call add(lines, '│' . repeat(' ', a:width) . '│')
  endfor
  call add(lines, '╰' . repeat('─', a:width) . '╯')

  return lines
endfunction

function! s#popup(command, opts)
  let width  = get(a:opts, 'width', 0.6)
  let height = get(a:opts, 'height', 0.6)

  if has('nvim')
    let width = type(width) == v:t_float ? float2nr(&columns * width) : width
    let height = type(height) == v:t_float ? float2nr(&lines * height) : height

    let top = float2nr((&lines - height) / 2) + 1
    let left = float2nr((&columns - width) / 2) + 1

    let border_buf = nvim_create_buf(v:false, v:true)
    call nvim_buf_set_lines(border_buf, 0, height + 2, v:false, s:window_border(width, height))
    let border_win = nvim_open_win(border_buf, 0, {
      \ 'relative': 'editor',
      \ 'width': width + 2,
      \ 'height': height + 2,
      \ 'row': top - 1,
      \ 'col': left - 1,
      \ 'style': 'minimal'
      \ })

    call nvim_win_set_option(border_win, 'winhl', 'Normal:SPopup')

    let buf = nvim_create_buf(v:false, v:true)
    let win = nvim_open_win(buf, 1, {
      \ 'relative': 'editor',
      \ 'width': width,
      \ 'height': height,
      \ 'row': top,
      \ 'col': left,
      \ 'style': 'minimal'
      \ })

    call nvim_win_set_option(win, 'winhl', 'Normal:SPopup')

    call termopen(a:command, {'on_exit': function('s:close_border_window', [border_win])})

    startinsert
  else
    echoerr "Not supported in VIM yet (can you imagine?)"
  end
endfunction

function! s:close_border_window(border_window_id, job_id, code, event)
  if a:code == 0
    close
    call nvim_win_close(a:border_window_id, v:true)
  endif
endfunction
