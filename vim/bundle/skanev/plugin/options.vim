" Appearance
set ruler
set wildmenu
set number
set nowrap
set showcmd

set incsearch
set hlsearch

" Behavior
set autoindent
set autoread
set ignorecase
set smartcase
set scrolloff=5

set modeline

set backspace=indent,eol,start

" set wildignore+=**/tmp/**
set nojoinspaces

" System
set dir=~/.vim-backup

if has('persistent_undo')
  set undodir=~/.vim-undo
  set undofile
end

" Highlight invisible characters
set listchars=eol:¬,tab:→\ 

" Status line
set laststatus=2

" GUI settings
if has('gui_running')
  set guioptions-=T
  set guioptions-=m
  set guioptions-=e
  set guioptions-=r
  set guioptions-=L
  if has("gui_gtk2")
    set guifont=DejaVu\ Sans\ Mono\ for\ Powerline\ 10
    set linespace=2
  elseif has("gui_macvim")
    set guifont=Monaco:h12
    set linespace=3
    set macmeta
  endif
else
  set t_Co=256
  set mouse=a
  set ttymouse=xterm2
end

" Colorscheme
if $VIM_COLORSCHEME != ""
  exec 'colorscheme '.$VIM_COLORSCHEME
elseif has('gui_gtk2')
  colorscheme native
elseif has('gui_running')
  colorscheme vividchalk
elseif $ITERM_PROFILE == "Beamer"
  colorscheme emacs
else
  colorscheme vividchalk
end
