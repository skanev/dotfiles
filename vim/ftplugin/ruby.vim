if exists('b:did_myftplugin') | finish | endif
let b:did_myftplugin = 1

setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
setlocal iskeyword+=!
setlocal iskeyword+=?

autocmd BufnewFile,BufRead *.rb setlocal complete-=i

map <Leader>f :AS<CR><C-w>r
xnoremap <Leader>e <ESC>:call s:ExtractVariable()<CR>
map <Leader>l <Cmd>call s:PromoteToLet()<CR>

imap <buffer> <C-l> <Space>=><Space>

map <buffer> [r :A<CR>
map <buffer> ]r :R<CR>

onoremap <buffer> i\| :<c-u>normal! T\|vt\|<CR>
onoremap <buffer> a\| :<c-u>normal! F\|vf\|<CR>

function! s:PromoteToLet()
  s/\v(\w+)\s+\=\s+(.*)$/let(:\1) { \2 }/
  normal ==
endfunction

function! s:ExtractVariable()
  try
    let save_a = @a
    let variable = input('Variable name: ')
    normal! gv"ay
    execute "normal! gvc" . variable
    execute "normal! O" . variable . " = " . @a
  finally
    let @a = save_a
  endtry
endfunction

