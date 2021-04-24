map <F1> :help skanev.txt<CR>
map <Leader>1 <F1>

map <F2> :BufExplorer<CR>
map <Leader>2 <F2>
map <Leader>b <F2>

map <F3> :NERDTreeToggle<CR>
map <S-F3> :NERDTreeFind<CR>
map <Leader>3 <F3>
map <Leader># <S-F3>
map <Leader>l <F3>
map <Leader>L <S-F3>

map <F6> :Scratch<CR>
map <Leader>6 <F6>

map <F8> :%s/<C-r><C-w>//gc<Left><Left><Left>
map <S-F8> :Ack <C-r><C-w><CR>
map <Leader>8 <F8>
map <Leader>* <S-F8>

map <F9> :noh<CR>
map <Leader>9 <F9>
map <LeadeR>n <F9>

map <F10> :set cursorcolumn!<CR>
map <Leader>0 <F10>
imap <F10> <C-o>:set cursorcolumn!<CR>

map <F11> :FZF ~/code/personal/dotfiles<CR>
map <S-F11> :FZF ~/.vim/<CR>

map <F12> :edit ~/.vim/vimrc.vim<CR>

map <Leader>- <F11>
map <Leader>= <F12>

map <Leader>p <Plug>(SynStack)

map <C-]> <Plug>(fzf_tags)

imap <expr> jk BulgarianJK()
nnoremap <Tab> <C-w><C-w>
nnoremap <S-Tab> <C-w><C-W>
nnoremap <C-p> <C-i>

nnoremap ,, ,
map <Space> :
map <expr> Q ''
map <Leader><Space> :

nmap yoa :ALEToggleBuffer<CR>

inoremap <S-Tab> <C-v><C-i>

map <C-Left> :bn<CR>
map <C-Right> :bp<CR>

MapMeta j 4j
MapMeta k 4k

MapMeta f :FZF<CR>
MapMeta p :FZF<CR>

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

if !(has('gui_running') && has('gui_macvim'))
  MapMeta s :w<CR>
  MapMeta w :close<CR>
  MapMeta t :tabnew<CR>
end
