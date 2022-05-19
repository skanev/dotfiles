let s:ftplugin_dir = fnamemodify(expand('<sfile>'), ':h:s?plugin?ftplugin?')

function! s:my_ftplugin_complete(arg_lead, line, pos)
  echo a:arg_lead
  return s#command_completion_helper(readdir(s:ftplugin_dir)->map({ _, name -> fnamemodify(name, ':r') }), a:arg_lead, a:line, a:pos)
endfunction

function! s:my_ftplugin(name)
  let type = ""
  if a:name != ""
    let type = a:name
  elseif &filetype == ''
    echohl ErrorMsg | echomsg 'Current buffer has no filetype' | echohl None
    return
  else
    let type = &filetype
  endif

  let filename = s:ftplugin_dir . '/' . type . '.vim'
  exec "split " . filename

  if !filereadable(filename)
    call append(0, [
          \ 'if exists("b:did_myftplugin") | finish | endif',
          \ 'let b:did_myftplugin = 1',
          \ ''
          \ ])
  endif
endfunction

command! -nargs=? -complete=customlist,s:my_ftplugin_complete MyFtplugin call s:my_ftplugin(<q-args>)

augroup my_ftplugin
  autocmd!
  autocmd User ResetCustomizations unlet! b:did_myftplugin
augroup END
