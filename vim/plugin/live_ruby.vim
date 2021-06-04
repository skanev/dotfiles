let s:callbacks = {}
let s:data = {}

function! s:on_event(job_id, data, event)
  if a:event == 'stdout'
    if a:data == [''] | return | endif
    call extend(s:data[a:job_id].stdout, a:data)
  elseif a:event == 'stderr'
    if a:data == [''] | return | endif "
    call extend(s:data[a:job_id].stderr, a:data)
  else
    if a:data == 0
      let annotations = json_decode(join(s:data[a:job_id].stdout, "\n"))
      call s:annotate(s:data[a:job_id].bufnr, annotations)
    else
      echo get(s:data[a:job_id].stderr, 0, 'Command failed')
    endif

    unlet s:data[a:job_id]
  endif
endfunction

function! s:run(command)
  let job_id = jobstart(a:command, s:callbacks)
  let s:data[job_id] = {'stdout': [], 'stderr': [], 'finished': 0}
endfunction

function! s:annotate(bufnr, annotations)
  let ns = nvim_create_namespace(expandcmd("live-ruby:%"))
  call nvim_buf_clear_namespace(a:bufnr, ns, 0, -1)

  for [line, message] in items(a:annotations)
    call nvim_buf_set_virtual_text(a:bufnr, ns, str2nr(line), [[message, 'Comment']], {})
  endfor
endfunction

function! s:check(bufnr)
  let script_path = g:dotfiles_dir . '/vim/scripts/live-ruby-run.rb'
  let file_path = expand('%:p')
  let job_id = jobstart(printf('timeout 2 ruby %s %s', script_path, file_path), s:callbacks)
  let s:data[job_id] = {'stdout': [], 'stderr': [], 'bufnr': a:bufnr, 'finished': 0}
endfunction

function! s:establish() abort
  if &filetype != 'ruby'
    throw "Filetype is not ruby, but: " . &filetype
  endif

  augroup LiveRuby
    autocmd! * <buffer>
    autocmd BufWritePost <buffer> call <SID>check(bufnr())
  augroup END

  map <buffer> Q :!ruby %<CR>

  write
endfunction

let s:callbacks.on_stdout = function('s:on_event')
let s:callbacks.on_stderr = function('s:on_event')
let s:callbacks.on_exit   = function('s:on_event')

command -nargs=0 LiveRuby call <SID>establish()
