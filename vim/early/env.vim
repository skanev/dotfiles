" Determines a few things about the running instance of vim that we are going
" to need later to make various decisions.

let g:env = {}
let g:env.wsl = exists('$WSLENV')

if has('gui_running')
  if     has('gui_macvim')                  | let g:env.app = 'mvim'
  elseif has('gui_gtk3') || has('gui_gtk2') | let g:env.app = 'gvim'
  elseif has('gui_win32')                   | let g:env.app = 'winvim'
  elseif has('gui_vimr')                    | let g:env.app = 'vimr'
  else                                      | let g:env.app = 'unknown-gui'
  endif
elseif has('nvim')
  if exists('g:neovide')          | let g:env.app = 'neovide'
  elseif exists('goneovim')       | let g:env.app = 'goneovim'
  elseif exists('g:GtkGuiLoaded') | let g:env.app = 'nvim-gtk'
  elseif exists('g:fvim_loaded')  | let g:env.app = 'fvim'
  elseif exists('$NVIM_QT')       | let g:env.app = 'nvim-qt'
  else                            | let g:env.app = 'nvim'
  endif
else
  let g:env.app = 'vim'
endif

if     exists('$HOMEDRIVE')  | let g:env.os = 'windows'
elseif exists('$WSLENV')     | let g:env.os = 'wsl'
elseif $DOTFILES_OS == 'mac' | let g:env.os = 'mac'
else                         | let g:env.os = 'unknown'
endif

function! s:oneof(value, things)
  return index(a:things, a:value) >= 0
endfunction

let g:env.tmux = $TMUX != "" && (g:env.app == 'vim' || g:env.app == 'nvim')
let g:env.meta_key = g:env.os == 'mac' && s:oneof(g:env.app, ['mvim', 'vimr', 'neovide', 'nvim-qt', 'goneovim', 'fvim']) ? 'D' : 'M'

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
