command! MyFtplugin call s:my_ftplugin()
command! E call s:reload_ftplugin()

let s:ftplugin_dir = fnamemodify(expand('<sfile>'), ':h:s?plugin?ftplugin?')

function! s:reload_ftplugin()
  unlet! b:did_myftplugin
  edit
endfunction

function! s:my_ftplugin()
  if &filetype == ''
    echohl ErrorMsg | echomsg 'Current buffer has no filetype' | echohl None
    return
  endif

  let filename = s:ftplugin_dir . '/' . &filetype . '.vim'
  exec "split " . filename

  if !filereadable(filename)
    call append(0, [
          \ 'if exists("b:did_myftplugin") | finish | endif',
          \ 'let b:did_myftplugin = 1',
          \ ''
          \ ])
  endif
endfunction
