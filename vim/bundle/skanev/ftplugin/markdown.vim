if (exists("b:did_skanev_ftplugin"))
  finish
endif
let b:did_skanev_ftplugin = 1

set tabstop=4 softtabstop=4 shiftwidth=4 expandtab
onoremap i$ :<c-u>normal! T$vt$<CR>
setlocal spell
set tw=78
