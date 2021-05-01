" Some commands (like map or autocmd) create a lot of output. There is a
" semi-useful pager in terminal vim, but nothing close in gVim/MacVim. Thus,
" having a way to capture the output is very, very useful.

command! -nargs=+ Capture call s:capture(<q-args>)

cnoremap <C-g><CR> <Home>Capture<Space><CR>

function! s:capture(command)
  let saved_p = @p
  redir @p
  execute "silent" a:command
  redir END

  call s:open_capture()

  normal "pp
  normal ggdd

  let @p = saved_p
endfunction

function! s:open_capture()
  if !bufexists('CAPTURE')
    tabnew CAPTURE
    setlocal buftype=nofile
    setlocal nobuflisted
    setlocal bufhidden=wipe
    setlocal noswapfile
  elseif buflisted('CAPTURE')
    edit CAPTURE
  else
    tabnew CAPTURE
  endif
endfunction
