" Determines a few things about the running instance of vim that we are going
" to need later to make various decisions.

let g:env = {}
let g:env.gui = has('gui_running')
let g:env.term = !g:env.gui
let g:env.wsl = $WSLENV != ""
let g:env.tmux = $TMUX != "" && !has('gui_running')

if has('gui_running')
  if has('gui_macvim')
    let g:env.kind = 'macvim'
  elseif has('gui_win32')
    let g:env.kind = 'winvim'
  elseif has('gui_gtk3') || has('gui_gtk2')
    let g:env.kind = 'gvim'
  else
    let g:env.kind = 'unknown'
  endif
else
  let g:env.kind = 'terminal'
endif

let g:env.term = g:env.kind == 'terminal'

if g:env.term
  let g:env.profile = 'terminal'
elseif g:env.gui && g:env.wsl
  let g:env.profile = 'gvim-wsl'
elseif g:env.gui && g:env.kind == 'winvim'
  let g:env.profile = 'winvim'
elseif g:env.gui && g:env.kind == 'macvim'
  let g:env.profile = 'macvim'
else
  let g:env.profile = 'unknown'
endif

augroup Env
  autocmd! VimEnter * call s:on_late_startup()
augroup END

command! DisplayEnv call s:display_env()

function! s:display_env()
  for [key, value] in items(g:env)
    echomsg "let g:env." . printf("%-7s", key) . " = " . value
  endfor
endfunction

function! s:on_late_startup()
  augroup Env
    autocmd!
  augroup end

  call timer_start(50, s:sid() . 'trigger_autocommand')
endfunction

function! s:sid()
  return '<SNR>' . matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$') . '_'
endfunction

function! s:trigger_autocommand(timer)
  silent! doautocmd User SafeStartup
endfunction
