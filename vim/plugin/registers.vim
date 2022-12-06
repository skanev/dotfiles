function! s:clear_registers()
  for i in split('abcdefghijklmnopqrstuvwxyz0123456789*+-"', '\zs')
    call setreg(i, [])
  endfor
endfunction

command! ClearRegisters call s:clear_registers()
