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
    set guifont=Monaco\ for\ Powerline:h14
    set linespace=3
    set macmeta
  endif
else
  set t_Co=256
  set mouse=a
end

" Colorscheme
if $VIM_COLORSCHEME != ""
  exec 'colorscheme '.$VIM_COLORSCHEME
elseif has('gui_gtk2')
  colorscheme native
elseif has('gui_running')
  let g:sonokai_style = 'shusia'
  colorscheme sonokai
  hi TabLineSel guibg=#6b6a75 guifg=#ffffff
  hi VertSplit guifg=#e5c463
  hi Cursor guibg=#000000 guifg=#ffffff
  hi link rubySymbol Purple
  hi link rubyInterpolation White
  hi link rubyInterpolationDelimiter Orange
  hi link rubyModuleName rubyClassName
  hi link rubyMacro Orange
  hi link perlVarPlain Blue

  "colorscheme vividchalk
elseif $ITERM_PROFILE == "Beamer"
  colorscheme emacs
else
  "colorscheme vim-monokai-tasty
  colorscheme vividchalk
end
