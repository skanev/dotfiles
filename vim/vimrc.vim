syntax on
set nocompatible

" My 'early' stuff
runtime bundle/skanev/early/mapmeta.vim

" Pathogen and Vundle
filetype off
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()
set runtimepath+=~/.vim/vundle/vundle
call vundle#rc('~/.vim/vundle')

let g:notes_directories = ['~/Dropbox/Notes']

" Bundles
Bundle 'vundle'
Bundle 'tpope/vim-haml'
Bundle 'tpope/vim-surround'
Bundle 'tpope/vim-cucumber'
Bundle 'scrooloose/syntastic'
Bundle 'tpope/vim-rails'
Bundle 'godlygeek/tabular'
Bundle 'vim-ruby/vim-ruby'
Bundle 'michaeljsmith/vim-indent-object'
Bundle 'scrooloose/nerdcommenter'
Bundle 'skanev/vim-nexus'
Bundle 'ervandew/supertab'
Bundle 'extradite.vim'
Bundle 'slim-template/vim-slim'
Bundle 'altercation/vim-colors-solarized'
Bundle 'tpope/vim-unimpaired'
Bundle 'tpope/vim-endwise'
Bundle 'kchmck/vim-coffee-script'
Bundle 'kien/rainbow_parentheses.vim'
Bundle 'thinca/vim-prettyprint'
Bundle 'vim-scripts/Decho'
Bundle 'ack.vim'
Bundle 'The-NERD-tree'
Bundle 'xolox/vim-misc'
Bundle 'notes.vim'
Bundle 'tpope/vim-fireplace'
Bundle 'tpope/vim-classpath'
Bundle 'guns/vim-clojure-static'
Bundle 'paredit.vim'
Bundle 'Gist.vim'
Bundle 'WebAPI.vim'
Bundle 'digitaltoad/vim-jade'
Bundle 'groenewege/vim-less'
Bundle 'scratch.vim'
Bundle 'bling/vim-airline'
Bundle 'go.vim'
Bundle 'ctrlp.vim'
Bundle 'fugitive.vim'
Bundle 'Gundo'
Bundle 'AndrewRadev/switch.vim'
Bundle 'AndrewRadev/sideways.vim'
Bundle 'AndrewRadev/splitjoin.vim'
Bundle 'nginx.vim'

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
let g:airline_powerline_fonts = 1
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_branch_prefix= ''
let g:airline_readonly_symbol = ''
let g:airline_linecolumn_prefix = ''
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ''
let g:airline#extensions#tabline#left_alt_sep = ''
let g:airline#extensions#tabline#show_buffers = 0

" Disable netrw
let g:loaded_netrw = 1
let g:loaded_netrwPlugin = 1

map [f :A<CR>
map ]f :R<CR>

function! PromoteToLet()
  s/\v(\w+)\s+\=\s+(.*)$/let(:\1) { \2 }/
  normal ==
endfunction

command! PromoteToLet :call PromoteToLet()
map <Leader>l :PromoteToLet<CR>

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

set keymap=bulgarian-bds
set iminsert=0
set imsearch=-1
cnoremap <C-c> <C-^>
inoremap <C-c> <C-^>

runtime localvimrc

"function GetFooText()
  "return localtime()
"endfunction

"call airline#parts#define_function('foo', 'GetFooText')

"function! AirlineInit()
"endfunction
  "let g:airline_section_y = airline#section#create(['foo', ' ', 'ffenc'])
"autocmd VimEnter * call AirlineInit()
