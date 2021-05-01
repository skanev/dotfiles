if exists('b:did_myftplugin') | finish | endif
let b:did_myftplugin = 1

setlocal joinspaces
setlocal textwidth=72
setlocal shiftwidth=2 tabstop=2 softtabstop=2 expandtab
setlocal spelllang=en,bg spell

imap <buffer> -- –

map <buffer> Q :PreviewMarkdown<CR>
command! -buffer PreviewMarkdown call s:PreviewMarkdown()

function! s:Initialize()
  if (exists("b:markdown_file"))
    return
  endif

  augroup mail_preview
    autocmd!
    autocmd BufWritePost <buffer> call s:SaveMarkdownPreview()
  augroup END

  let b:markdown_file = tempname() . ".markdown"
endfunction

function! s:SaveMarkdownPreview()
  silent call system("touch " . expand('%'))
  silent call system("~/.mutt/bin/markdown " . b:markdown_file . " < " . expand('%') . ' &')
endfunction

function! s:PreviewMarkdown()
  call s:Initialize()
  call s:SaveMarkdownPreview()
  call system("open -a 'Markoff' " . b:markdown_file)
endfunction
