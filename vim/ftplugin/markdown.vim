if exists('b:did_myftplugin') | finish | endif
let b:did_myftplugin = 1

setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab
onoremap <buffer> i$ :<c-u>normal! T$vt$<CR>
map <buffer> Q :!open -a 'Markoff' %<CR><CR>
setlocal spell
setlocal spelllang=en,bg
setlocal tw=80

set textwidth=120

command! -buffer MarkdownToc :!markdown-toc -i %
