if exists("b:did_myftplugin") | finish | endif
let b:did_myftplugin = 1

set softtabstop=2 tabstop=2 shiftwidth=2 expandtab
let b:switch_custom_definitions =
    \ [
    \   {
    \     'it(': 'pending(',
    \     'pending(': 'it(',
    \   },
    \ ]

if s#starts_with(expand('%'), g:dotfiles_dir)
  map <buffer> Q <Cmd>luafile %<CR>
endif
