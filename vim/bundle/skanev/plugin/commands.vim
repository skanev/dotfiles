command! CloseHiddenBuffers call s:CloseHiddenBuffers()
command! MyFileTypePlugin call s:MyFileTypePlugin()
command! -nargs=+ Page call s:Page(<q-args>)

function! s:CloseHiddenBuffers()
  let open_buffers = []

  for i in range(tabpagenr('$'))
    call extend(open_buffers, tabpagebuflist(i + 1))
  endfor

  for num in range(1, bufnr("$") + 1)
    if buflisted(num) && index(open_buffers, num) == -1
      exec "bdelete ".num
    endif
  endfor
endfunction

let s:ftplugin_dir = fnamemodify(expand('<sfile>'), ':h:s?plugin?ftplugin?')
function! s:MyFileTypePlugin()
  if &filetype == ''
    echohl ErrorMsg | echomsg 'Current buffer has no filetype' | echohl None
    return
  endif

  let filename = s:ftplugin_dir . '/' . &filetype . '.vim'
  exec "split " . filename

  if !filereadable(filename)
    call append(0, [
          \ 'if (exists("b:did_skanev_ftplugin"))',
          \ '  finish',
          \ 'endif',
          \ 'let b:did_skanev_ftplugin = 1',
          \ ''
          \ ])
  endif
endfunction

function! s:Page(command)
  let saved_p = @p
  redir @p
  execute "silent" a:command
  redir END

  call s:OpenPager()

  normal "pp

  let @p = saved_p
endfunction

function! s:OpenPager()
  if !bufexists('PAGER')
    tabnew PAGER
    setlocal buftype=nofile
    setlocal nobuflisted
    setlocal bufhidden=wipe
    setlocal noswapfile
  elseif buflisted('PAGER')
    edit PAGER
  else
    tabnew PAGER
  endif
endfunction
