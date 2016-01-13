set nocompatible
let mapleader = ","

" My 'early' stuff
runtime bundle/skanev/early/term.vim
runtime bundle/skanev/early/mapmeta.vim

" Pathogen and Vundle
filetype off
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()

call plug#begin("~/.vim/plugged")

Plug 'tpope/vim-haml'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-cucumber'
Plug 'scrooloose/syntastic'
Plug 'tpope/vim-rails'
Plug 'godlygeek/tabular'
Plug 'vim-ruby/vim-ruby'
Plug 'michaeljsmith/vim-indent-object'
Plug 'scrooloose/nerdcommenter'
Plug 'skanev/vim-nexus'
Plug 'ervandew/supertab'
Plug 'extradite.vim'
Plug 'onemanstartup/vim-slim'
Plug 'altercation/vim-colors-solarized'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-endwise'
Plug 'kchmck/vim-coffee-script'
Plug 'kien/rainbow_parentheses.vim'
Plug 'thinca/vim-prettyprint'
Plug 'vim-scripts/Decho'
Plug 'ack.vim'
Plug 'The-NERD-tree'
Plug 'xolox/vim-misc'
Plug 'tpope/vim-fireplace'
Plug 'tpope/vim-classpath'
Plug 'paredit.vim'
Plug 'Gist.vim'
Plug 'WebAPI.vim'
Plug 'digitaltoad/vim-jade'
Plug 'groenewege/vim-less'
Plug 'scratch.vim'
Plug 'bling/vim-airline'
Plug 'go.vim'
Plug 'ctrlp.vim'
Plug 'tpope/vim-fugitive'
Plug 'Gundo'
Plug 'AndrewRadev/switch.vim'
Plug 'AndrewRadev/sideways.vim'
Plug 'AndrewRadev/splitjoin.vim'
Plug 'nginx.vim'
Plug 'tejr/vim-tmux'
Plug 'mtscout6/vim-cjsx'

call plug#end()
"set runtimepath+=~/.vim/vundle/vundle
"call vundle#begin('~/.vim/vundle')

let g:notes_directories = ['~/Dropbox/Notes']

" Bundles
" Bundle 'vundle'
"
"call vundle#end()

filetype plugin indent on

let g:splitjoin_split_mapping = ''
let g:splitjoin_join_mapping = ''

" Suppress DEcho's dependency's <Leader>s overriding
nmap <unique> <Leader>SWP <Plug>SaveWinPosn
nmap <unique> <Leader>RWP <Plug>RestoreWinPosn

nmap <Leader>j :SplitjoinJoin<CR>
nmap <Leader>s :SplitjoinSplit<CR>

nnoremap <C-h> :SidewaysLeft<CR>
nnoremap <C-l> :SidewaysRight<CR>

nnoremap - :Switch<CR>

source ~/.vim/bundle/skanev/other/airline-theme.vim

" Airline configruation
let g:airline_theme = 'skanev'
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''


if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ''

" Disable netrw
let g:loaded_netrw = 1
let g:loaded_netrwPlugin = 1

" Gist
let g:gist_clip_command = 'pbcopy'
let g:gist_open_browser_after_post = 1
let g:gist_post_private = 1

" Syntastic
let g:syntastic_enable_signs=1

" CtlrP
let g:ctrlp_custom_ignore = {
  \ 'dir': '\v(vundle|vim-backup|vim-undo)|([\/]\.(git|hg|svn)$)',
  \ }
let g:ctrlp_working_path_mode = '0'

map [f :A<CR>
map ]f :R<CR>

function! PromoteToLet()
  s/\v(\w+)\s+\=\s+(.*)$/let(:\1) { \2 }/
  normal ==
endfunction

command! PromoteToLet :call PromoteToLet()
map <Leader>l :PromoteToLet<CR>

command! Reverse :g/^/m0
map <F4> :tabedit BECKLIST<CR>

function! ExtractVariable()
  try
    let save_a = @a
    let variable = input('Variable name: ')
    normal! gv"ay
    execute "normal! gvc" . variable
    execute "normal! O" . variable . " = " . @a
  finally
    let @a = save_a
  endtry
endfunction
xnoremap <Leader>e <ESC>:call ExtractVariable()<CR>

let vimclojure#WantNailgun = 1
let vimclojure#NailgunClient = "/Users/aquarius/code/runtimes/vim-clojure-nailgun/ng"

augroup skanev
  autocmd!
  autocmd InsertEnter * :silent set timeoutlen=200
  autocmd InsertLeave * :silent set timeoutlen=1000
augroup END

set keymap=bulgarian-skanev
set iminsert=0
set imsearch=-1
cnoremap <C-c> <C-^>
inoremap <C-c> <C-^>

" Syntastic is far too slow for SCSS
let g:syntastic_scss_checkers = []
let g:syntastic_slim_checkers = []

runtime localvimrc

"function GetFooText()
  "return localtime()
"endfunction

"call airline#parts#define_function('foo', 'GetFooText')

"function! AirlineInit()
"endfunction
  "let g:airline_section_y = airline#section#create(['foo', ' ', 'ffenc'])
"autocmd VimEnter * call AirlineInit()
