function! s:clear_marks()
  delmarks!
  delmarks A-Z0-9
endfunction

command! ClearMarks call s:clear_marks()
