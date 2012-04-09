if !has('gui_gtk2')
  finish
endif

map <M-s> :w<CR>
map <M-w> <C-w>c
map <M-f> <Leader>t
map <M-t> :tabnew<CR>

map <M-v> "+p
vmap <M-c> "+y
imap <M-v> <C-r>+

command! Commit execute "!git gui"
