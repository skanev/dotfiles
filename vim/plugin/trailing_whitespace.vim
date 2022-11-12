" Highlight all trailing whitespace in normal mode.
"
" I don't want trailing whitespace highlighted when in insert mode,
" because it distracts me when there is a red square on every space
" or tab I type.

let g:HighlightTrailingWhitespace = 1

highlight TrailingWhitespace guibg=red ctermbg=red

autocmd! BufEnter,FileType * call s:highlight()
autocmd! ModeChanged       * call s:on_mode_change()
autocmd! ColorScheme       * highlight TrailingWhitespace guibg=red ctermbg=red

":: Trailing Whitespace: Strip
command! StripTrailingWhitespace  call s:strip()
":: Trailing Whitespace: Toggle showing
command! TrailingWhitespaceToggle call s:toggle()

function! s:highlight()
  let enabled = &buftype != 'nofile' && &buftype != 'terminal' &&
        \ g:HighlightTrailingWhitespace &&
        \ (!exists('b:highlight_trailing_whitespace') || b:highlight_trailing_whitespace)

  if enabled
    match TrailingWhitespace /\v\s+$/
  else
    match none
  endif
endfunction

function! s:unhighlight()
  match none
endfunction

function s:toggle()
  let g:HighlightTrailingWhitespace = !g:HighlightTrailingWhitespace
endfunction

function! s:strip()
  let pattern = @/
  %s/\s\+$//e
  let @/ = pattern
endfunction

function! s:on_mode_change() abort
  if mode()[0] == 'i' || mode()[0] == 's' || mode()[0] == 'c'
    call s:unhighlight()
  else
    call s:highlight()
  endif
endfunction
