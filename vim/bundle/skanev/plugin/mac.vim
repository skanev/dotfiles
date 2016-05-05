if !has('gui_macvim')
  finish
endif

command! Mate !mate %
map <silent> <D-w> :close<CR>
