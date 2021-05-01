" Highlight all trailing whitespace in normal mode.
"
" I don't want trailing whitespace highlighted when in insert mode,
" because it distracts me when there is a red square on every space
" or tab I type.

let g:HighlightTrailingWhitespace = 1

highlight TrailingWhitespace guibg=red ctermbg=red

autocmd! InsertLeave,WinEnter * call s:highlight()
autocmd! InsertEnter          * call s:unhighlight()
autocmd! ColorScheme          * highlight TrailingWhitespace guibg=red ctermbg=red

command! StripTrailingWhitespace  %s/\v\s+$//
command! TrailingWhitespaceToggle call s:toggle()

function! s:highlight()
  let enabled = g:HighlightTrailingWhitespace && 
        \ (!exists('b:highlight_trailing_whitespace') || b:highlight_trailing_whitespace)

  if enabled
    match TrailingWhitespace /\v\s+$/
  endif
endfunction

function! s:unhighlight()
  match none
endfunction

function s:toggle()
  let g:HighlightTrailingWhitespace = !g:HighlightTrailingWhitespace
endfunction
