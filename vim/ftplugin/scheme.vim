if (exists("b:did_skanev_ftplugin"))
  finish
endif
let b:did_skanev_ftplugin = 1

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
