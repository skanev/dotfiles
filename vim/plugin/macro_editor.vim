let s:bufferName = "\\[MacroEditor\\]"

function! s:MacroEditorOpen(register)
  let bufnum = bufnr(s:bufferName)

  if bufnum == -1
    5new [MacroEditor]
  else
    let winnum = bufwinnr(bufnum)
    if winnum != -1
      if winnr() != winnum
        exe winnum . "wincmd w"
      endif
    else
      exe "5split +buffer" . bufnum
    endif
  endif

  call deletebufline(s:bufferName, '1', '$')
  call appendbufline(s:bufferName, '0', a:register)
  call appendbufline(s:bufferName, '1', getreg(a:register))
  call deletebufline(s:bufferName, '$')
endfunction

function! s:LoadMacro()
  let register = getbufline(s:bufferName, '1')[0]
  let contents = getbufline(s:bufferName, '2')[0]
  call setreg(register, contents)
endfunction

function! s:SetupBuffer()
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal nobuflisted

  map <buffer> Q <Cmd>call <SID>LoadMacro()<CR>
endfunction

autocmd BufNewFile \[MacroEditor\] call s:SetupBuffer()

command! -nargs=1 EditMacro call s:MacroEditorOpen('<args>')
