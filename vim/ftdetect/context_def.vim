autocmd BufNewFile,BufReadPost */contexts/* if fnamemodify(bufname('%'), ':p:h:t') == 'contexts' | setfiletype context_def | endif
