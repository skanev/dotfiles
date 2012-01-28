if (exists("b:did_skanev_ftplugin"))
  finish
endif
let b:did_skanev_ftplugin = 1

imap <buffer> <C-l> <Space>=><Space>

set tabstop=2 softtabstop=2 shiftwidth=2 expandtab

autocmd BufnewFile,BufRead *.rb setlocal complete-=i
