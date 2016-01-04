map <F1> :help skanev.txt<CR>
map <F2> :BufExplorer<CR>
map <F3> :NERDTreeToggle<CR>
map <S-F3> :NERDTreeFind<CR>

map <F6> :Scratch<CR>
map <F8> :%s/<C-r><C-w>//gc<Left><Left><Left>
map <S-F8> :Ack <C-r><C-w><CR>
map <F9> :noh<CR>
map <F10> :set cursorcolumn!<CR>
imap <F10> <C-o>:set cursorcolumn!<CR>

map <F11> :CtrlP ~/code/personal/dotfiles<CR>
map <S-F11> :CtrlP ~/.vim/<CR>

map <F12> :edit ~/.vim/vimrc.vim<CR>

imap <expr> jk BulgarianJK()
nnoremap <Tab> <C-w><C-w>
nnoremap <S-Tab> <C-w><C-W>
nnoremap <C-p> <C-i>

map <expr> Q ''

inoremap <S-Tab> <C-v><C-i>

map <C-Left> :bn<CR>
map <C-Right> :bp<CR>

MapMeta j 4j
MapMeta k 4k

MapMeta f :CtrlP<CR>

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

MapMeta r <Plug>NexusRunTestFile
MapMeta R <Plug>NexusRunTestLine

MapMeta e <Plug>NexusSendBuffer
VMapMeta e <Plug>NexusSendSelection

MapMeta / <Plug>NERDCommenterToggle
VMapMeta / <Plug>NERDCommenterToggle
