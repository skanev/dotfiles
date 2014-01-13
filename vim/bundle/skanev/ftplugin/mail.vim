if (exists("b:did_skanev_ftplugin"))
  finish
endif
let b:did_skanev_ftplugin = 1

setlocal joinspaces
setlocal textwidth=72
setlocal shiftwidth=2 tabstop=2 softtabstop=2 expandtab
setlocal spelllang=en,bg spell

imap <buffer> -- –
