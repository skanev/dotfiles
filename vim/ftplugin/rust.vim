if exists("b:did_myftplugin") | finish | endif
let b:did_myftplugin = 1

" For some reason, the default vim ftplugin maps <D-r>. ABSOLUTELY INSANE
" https://github.com/vim/vim/blob/master/runtime/ftplugin/rust.vim#L139-L142
"nunmap <buffer> <D-r>
imap <C-l> <Space>=><Space>
