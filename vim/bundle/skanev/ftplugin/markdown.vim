if (exists("b:did_skanev_ftplugin"))
  finish
endif
let b:did_skanev_ftplugin = 1

set tabstop=4 softtabstop=4 shiftwidth=4 expandtab
onoremap i$ :<c-u>normal! T$vt$<CR>
map <buffer> Q :!open -a 'Markoff' %<CR><CR>
setlocal spell
setlocal spelllang=en,bg
set tw=78
