syntax on

" Pathogen
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()

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

" Keys
map <F2> :BufExplorer<CR>
map <F3> :NERDTreeToggle<CR>
map <S-F5> :source ~/.vimrc<CR>
map <S-F4> :edit ~/.vim/vimrc.vim<CR>

nmap <Tab> <C-w><C-w>

map <D-F1> :tabnext 1<CR>
map <D-F2> :tabnext 2<CR>
map <D-F3> :tabnext 3<CR>
map <D-F4> :tabnext 4<CR>
map <D-F5> :tabnext 5<CR>

if has('gui_running')
  imap <D-S> <C-O>:w<CR>
end

" Highlight invisible characters
set listchars=eol:⌙,tab:→\ 
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
    set guifont=Monaco:h10
  endif
else
  colorscheme modified_default
end

" Rails autocommands
autocmd User Rails silent! Rnavcommand specmodel spec/models -glob=**/* -suffix=_spec.rb -default=model()
autocmd User Rails silent! Rnavcommand speccontroller spec/controllers -glob=**/* -suffix=_controller_spec.rb -default=controller()
autocmd User Rails silent! Rnavcommand spechelper spec/helpers -glob=**/* -suffix=_helper_spec.rb -default=controller()
autocmd User Rails silent! Rnavcommand specview spec/views -glob=**/* -suffix=.html.erb_spec.rb -default=controller()
autocmd User Rails silent! Rnavcommand stepdef features/step_definitions -suffix=_steps.rb
autocmd User Rails silent! Rnavcommand feature features/ -suffix=.feature
autocmd User Rails silent! Rnavcommand sass public/stylesheets/sass/ -suffix=.sass

" Some Scheme Stuff
" TODO This should be moved out of here
autocmd BufnewFile,BufRead *-test.ss map <buffer> Q :!mzscheme %<CR>

" Enable filetype plugins
filetype plugin on
