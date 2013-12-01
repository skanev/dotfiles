" Highlight all trailing whitespace in normal mode.
"
" I don't want trailing whitespace highlighted when in insert mode,
" because it distracts me when there is a red square on every space
" or tab I type.
"
" It can be temporary turned of by setting g:HighlightTrailingWhitespace to 0

let g:HighlightTrailingWhitespace = 1

autocmd! InsertLeave,WinEnter * call s:Highlight()
autocmd! InsertEnter *          call s:Unhighlight()

highlight TrailingWhitespace guibg=red

function! s:Highlight()
  if g:HighlightTrailingWhitespace
    match TrailingWhitespace /\v\s+$/
  endif
endfunction

function! s:Unhighlight()
  match none
endfunction

command! StripTrailingWhitespace %s/\v\s+$//
