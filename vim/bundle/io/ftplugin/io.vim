if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

set tabstop=4 softtabstop=4 shiftwidth=4 expandtab

nmap Q :!io %<CR>

" vim:set sw=2:
