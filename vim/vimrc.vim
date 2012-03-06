syntax on

" Pathogen
filetype off
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()
filetype plugin on

runtime bundle/skanev/early/mapmeta.vim

let Tlist_Show_One_File=1

" This has to be in .vimrc, since NERDTree is... far-sighted
let NERDTreeHijackNetrw=0

map [f :A<CR>
map ]f :R<CR>
