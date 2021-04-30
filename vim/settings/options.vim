set ruler
set wildmenu
set number
set nowrap
set showcmd

set incsearch
set hlsearch

set autoindent
set autoread
set ignorecase
set smartcase
set scrolloff=5

set modeline

set backspace=indent,eol,start

set nojoinspaces

set belloff=all

set dir=~/.vim-backup

if has('persistent_undo')
  set undodir=~/.vim-undo
  set undofile
end

set listchars=eol:¬,tab:→\ 

set laststatus=2

let s:themes = {
      \ 'gvim-wsl': ['Monospace Regular 12', 2],
      \ 'macvim':   ['Monaco for Powerline:h14', 2],
      \ 'winvim':   ['Consolas:h14', 3],
      \}

if g:env.term
  set t_Co=256
  set mouse=a
  if has('termguicolors')
    set termguicolors
  endif
else
  set guioptions-=T
  set guioptions-=m
  set guioptions-=e
  set guioptions-=r
  set guioptions-=L

  let [font, lineheight] = s:themes[g:env.profile]

  let &guifont = font
  let &linespace = lineheight
endif

if $VIM_COLORSCHEME != ""
  exec 'colorscheme '.$VIM_COLORSCHEME
elseif g:env.gui
  let g:sonokai_style = 'shusia'
  colorscheme sonokai
else
  colorscheme vividchalk
end
