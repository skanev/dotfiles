if !has('gui_gtk2')
  finish
endif

map <M-s> :w<CR>
map <M-w> <C-w>c
map <M-f> <Leader>t
map <M-t> :tabnew<CR>

map <M-v> "+p
vmap <C-c> "+y
imap <C-v> <C-r>+
