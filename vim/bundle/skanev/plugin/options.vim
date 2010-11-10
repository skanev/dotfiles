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

" System
set dir=~/.vim-backup

" Highlight invisible characters
set listchars=eol:¬,tab:→\ 
set list

" Status line
set laststatus=2
set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [ASCII=\%03.3b]\ [HEX=\%02.2B]%=[%=POS=%03l,%03c][%p%%]\ [LEN=%L]

" GUI settings
if has('gui_running')
  colorscheme vibrantink
  if has("gui_gtk2")
    set guifont=Terminus
  elseif has("gui_macvim")
    set guifont=Monaco:h12
    set macmeta
  endif
else
  colorscheme modified_default
end
