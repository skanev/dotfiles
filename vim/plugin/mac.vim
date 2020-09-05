if !has('gui_macvim') || !has('gui_running')
  finish
endif

command! Mate !mate %
map <silent> <D-w> :close<CR>
