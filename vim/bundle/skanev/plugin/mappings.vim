map <F1> :help skanev.txt<CR>
map <F2> :BufExplorer<CR>
map <F3> :NERDTreeToggle<CR>
map <F4> :TlistToggle<CR>

map <F9> :noh<CR>

map <F12> :edit ~/.vim/vimrc.vim<CR>
map <S-F12> :source ~/.vimrc<CR>

nmap <Tab> <C-w><C-w>
nmap <S-Tab> <C-w><C-W>

map <expr> Q ''

imap <C-a> <C-o>0
imap <C-e> <C-o>$

MapMeta j 4j
MapMeta k 4k

map <Space> :

MapMeta 1 :tabnext 1<CR>
MapMeta 2 :tabnext 2<CR>
MapMeta 3 :tabnext 3<CR>
MapMeta 4 :tabnext 4<CR>
MapMeta 5 :tabnext 5<CR>
MapMeta 6 :tabnext 6<CR>
MapMeta 7 :tabnext 7<CR>
MapMeta 8 :tabnext 8<CR>
MapMeta 9 :tabnext 9<CR>

MapMeta ] >>
MapMeta [ <<

VMapMeta ] >gv
VMapMeta [ <gv

MapMeta r <Plug>NexusRunFile
MapMeta R <Plug>NexusRunLine
