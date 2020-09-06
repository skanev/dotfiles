if (exists("b:did_skanev_ftplugin"))
  finish
endif
let b:did_skanev_ftplugin = 1

setlocal textwidth=0 tabstop=2 softtabstop=2 shiftwidth=2 expandtab
setlocal iskeyword+=!
setlocal iskeyword+=?

imap <buffer> <C-l> <Space>=><Space>
imap <buffer> <S-CR> <br><CR>
