" Highlight all trailing whitespace in normal mode.
"
" I don't want trailing whitespace highlighted when in insert mode,
" because it distracts me when there is a red square on every space
" or tab I type.
"
autocmd! InsertLeave,WinEnter * call s:Highlight()
autocmd! InsertEnter *          call s:Unhighlight()

highlight TrailingWhitespace guibg=red

function! s:Highlight()
  match TrailingWhitespace /\v\s+$/
endfunction

function! s:Unhighlight()
  match none
endfunction
