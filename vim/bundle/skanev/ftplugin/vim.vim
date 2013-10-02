if (exists("b:did_skanev_ftplugin"))
  finish
endif
let b:did_skanev_ftplugin = 1

set tabstop=2 softtabstop=2 shiftwidth=2 expandtab
nmap <buffer> Q :source %<CR>
