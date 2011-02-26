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

" System
set dir=~/.vim-backup

if has('persistent_undo')
  set undodir=~/.vim-undo
  set undofile
end

" Highlight invisible characters
set listchars=eol:¬,tab:→\ 
set list

" Status line
set laststatus=2
set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [ASCII=\%03.3b]\ [HEX=\%02.2B]%=[%=POS=%03l,%03c][%p%%]\ [LEN=%L]

" GUI settings
if has('gui_running')
  colorscheme vividchalk
  set guioptions-=T
  if has("gui_gtk2")
    set guifont=Terminus
  elseif has("gui_macvim")
    set guifont=Inconsolata-dz:h14
    set linespace=3
    set macmeta
  endif
else
  colorscheme modified_default
end
