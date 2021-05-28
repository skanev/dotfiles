if exists('b:did_myftplugin') | finish | endif
let b:did_myftplugin = 1

MapMeta <buffer> \ :Tabularize /<Bar><CR>
setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
