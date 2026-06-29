if exists('b:did_myftplugin') | finish | endif
let b:did_myftplugin = 1

setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab
onoremap <buffer> i$ :<c-u>normal! T$vt$<CR>
map <buffer> Q :!open -a 'Markoff' %<CR><CR>
setlocal spell
setlocal spelllang=en

command! -buffer MarkdownToc :!markdown-toc -i %

function! s:AIFormatOn() abort
  let b:ai_format = 1
  setlocal wrap linebreak
  setlocal textwidth=0
  noremap <buffer> j gj
  noremap <buffer> k gk
  noremap <buffer> gj j
  noremap <buffer> gk k
  noremap <buffer> 0 g0
  noremap <buffer> $ g$
  noremap <buffer> g0 0
  noremap <buffer> g$ $
endfunction

function! s:AIFormatOff() abort
  let b:ai_format = 0
  setlocal nowrap
  setlocal textwidth=80
  silent! unmap <buffer> j
  silent! unmap <buffer> k
  silent! unmap <buffer> gj
  silent! unmap <buffer> gk
  silent! unmap <buffer> 0
  silent! unmap <buffer> $
  silent! unmap <buffer> g0
  silent! unmap <buffer> g$
endfunction

function! s:AIFormatToggle() abort
  if get(b:, 'ai_format', 0)
    call s:AIFormatOff()
  else
    call s:AIFormatOn()
  endif
endfunction

command! -buffer AIFormat call <SID>AIFormatToggle()
nnoremap <buffer> yom :AIFormat<CR>

call s:AIFormatOff()
