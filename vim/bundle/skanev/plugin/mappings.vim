map <F1> :help skanev.txt<CR>
map <F2> :BufExplorer<CR>
map <F3> :NERDTreeToggle<CR>

map <F7> :NERDTreeFind<CR>
map <F8> :%s/<C-r><C-w>//gc<Left><Left><Left>
map <F9> :noh<CR>
map <F10> :set cursorcolumn!<CR>
imap <F10> <C-o>:set cursorcolumn!<CR>

map <F11> :CommandT ~/.vim/<CR>

map <F12> :edit ~/.vim/vimrc.vim<CR>
map <S-F12> :source ~/.vimrc<CR>

imap jj <ESC>
imap jk <ESC>
nmap <Tab> <C-w><C-w>
nmap <S-Tab> <C-w><C-W>

map <expr> Q ''

imap <C-a> <C-o>0
imap <C-e> <C-o>$

inoremap <S-Tab> <C-v><C-i>

map <C-Left> :bn<CR>
map <C-Right> :bp<CR>

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

MapMeta r <Plug>NexusRunTest
MapMeta R <Plug>NexusRunTestLine

MapMeta e <Plug>NexusSendBuffer
VMapMeta e <Plug>NexusSendSelection

MapMeta / <Plug>NERDCommenterToggle
VMapMeta / <Plug>NERDCommenterToggle
