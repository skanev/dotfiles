if exists("b:did_myftplugin") | finish | endif
let b:did_myftplugin = 1

map <buffer> Q <Cmd>w<CR><Cmd>!i3-msg restart<CR><CR>
