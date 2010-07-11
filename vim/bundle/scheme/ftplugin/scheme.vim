setlocal comments=:;
setlocal define=^\\s*(define
setlocal formatoptions-=t
setlocal iskeyword+=+,-,*,/,%,<,=,>,:,$,?,!,@-@,94
setlocal lisp

setlocal comments^=:;;;,:;;,sr:#\|,mb:\|,ex:\|#
setlocal formatoptions+=croql

setlocal lispwords+=module,parameterize,let-values,let*-values,letrec-values
setlocal lispwords+=define-values,opt-lambda,case-lambda,syntax-rules,with-syntax,syntax-case
setlocal lispwords+=define-signature,unit,unit/sig,compund-unit/sig,define-values/invoke-unit/sig

setlocal shiftwidth=2
setlocal tabstop=2
setlocal softtabstop=2
setlocal expandtab
setlocal autoindent

function! s:RunScheme(file)
  execute "!mzscheme -f " . a:file
endfunction

function! RunTests()
  if match(expand("%:r"), "-test$") > 0
    call s:RunScheme(expand("%"))
    return
  end

  let s:testfile = expand("%:r") . "-test.ss"
  if filereadable(s:testfile)
    call s:RunScheme(s:testfile)
    return
  end

  echohl WarningMsg | echomsg "No tests defined" | echohl None | exe "normal \<Esc>"
endfunction

map <F5> :call RunTests()<CR>
