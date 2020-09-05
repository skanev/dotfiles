if (exists("b:did_skanev_ftplugin"))
  finish
endif
let b:did_skanev_ftplugin = 1

setlocal tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab
imap <buffer> <C-l> <Space>:=<Space>
