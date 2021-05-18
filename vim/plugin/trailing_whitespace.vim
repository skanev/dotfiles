" Highlight all trailing whitespace in normal mode.
"
" I don't want trailing whitespace highlighted when in insert mode,
" because it distracts me when there is a red square on every space
" or tab I type.

let g:HighlightTrailingWhitespace = 1

highlight TrailingWhitespace guibg=red ctermbg=red

autocmd! InsertLeave,BufEnter,FileType * call s:highlight()
autocmd! InsertEnter                   * call s:unhighlight()
autocmd! ColorScheme                   * highlight TrailingWhitespace guibg=red ctermbg=red

command! StripTrailingWhitespace  call s:strip()
command! TrailingWhitespaceToggle call s:toggle()

function! s:highlight()
  if &buftype == 'nofile'
    return
  endif

  let enabled = g:HighlightTrailingWhitespace &&
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
  %s/\s\+$//
  let @/ = pattern
endfunction
