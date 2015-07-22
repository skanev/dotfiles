" Highlight all trailing whitespace in normal mode.
"
" I don't want trailing whitespace highlighted when in insert mode,
" because it distracts me when there is a red square on every space
" or tab I type.

let g:HighlightTrailingWhitespace = 1

autocmd! InsertLeave,WinEnter * call s:Highlight()
autocmd! InsertEnter *          call s:Unhighlight()

highlight TrailingWhitespace guibg=red ctermbg=red

function! s:Highlight()
  if g:HighlightTrailingWhitespace && &filetype != 'mail'
    match TrailingWhitespace /\v\s+$/
  endif
endfunction

function! s:Unhighlight()
  match none
endfunction

function s:Toggle()
  let g:HighlightTrailingWhitespace = !g:HighlightTrailingWhitespace
endfunction

command! StripTrailingWhitespace %s/\v\s+$//
command! TrailingWhitespaceToggle call s:Toggle()
