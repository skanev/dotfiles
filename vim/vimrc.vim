syntax on

" Pathogen
filetype off
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()
filetype plugin on

runtime bundle/skanev/early/mapmeta.vim

let Tlist_Show_One_File=1

" Disable netrw
let g:loaded_netrw = 1
let g:loaded_netrwPlugin = 1

map [f :A<CR>
map ]f :R<CR>

call Pl#Theme#InsertSegment('nexus:status', 'after', 'scrollpercent')
