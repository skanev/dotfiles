" A debugging aid for ftplugins and contexts.
"
" The intention is to make it easy to test out some vimscript. In order to use
" it, just:
"
" 1. Open a split on the current file with some vimscript
" 2. Add EvaluateInOtherWindow to the top
" 3. Run with Q (source %) to execute the vimscript in the other buffer
"
" When the vimscript split is evaluated, it will encounter
" EvaluateInOtherWindow, which will exit immediatelly (for the purposes of
" source %), but also source the same file in the other window.
"
" I could have created a mapping/command, but laziness is not bad either

command! EvaluateInOtherWindow if s:evaluate_in_other_window(expand('<sfile>')) | finish | end

function! s:evaluate_in_other_window(script) abort
  if len(gettabinfo(tabpagenr())[0].windows) != 2
    echohl WarningMsg
    echo "Fewer or more than two windows currently open"
    echohl None
    return 1
  endif

  if exists('w:about_to_run_some_vim')
    unlet! w:about_to_run_some_vim
    return 0
  endif

  wincmd w
  let w:about_to_run_some_vim = 1
  execute "source " . a:script
  wincmd w

  return 1
endfunction
