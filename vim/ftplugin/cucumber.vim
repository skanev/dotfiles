if exists('b:did_myftplugin') | finish | endif
let b:did_myftplugin = 1

call MapMeta('n', '\ :Tabularize /<Bar><CR>', '<buffer>')
setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
