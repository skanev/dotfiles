command! CloseHiddenBuffers call s:CloseHiddenBuffers()
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
command! MyFileTypePlugin call s:MyFileTypePlugin()
function! s:MyFileTypePlugin()
  if &filetype == ''
    echohl ErrorMsg | echomsg 'Current buffer has no filetype' | echohl None
    return
  endif

  let filename = s:ftplugin_dir . '/' . &filetype . '.vim'
  exec "edit " . filename

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
