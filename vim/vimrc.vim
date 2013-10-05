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

let g:notes_directory = '~/Dropbox/Notes'

" Bundles
Bundle 'tpope/vim-fugitive'
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
Bundle 'int3/vim-extradite'
Bundle 'bbommarito/vim-slim'
Bundle 'altercation/vim-colors-solarized'
Bundle 'tpope/vim-unimpaired'
Bundle 'tpope/vim-endwise'
Bundle 'kchmck/vim-coffee-script'
Bundle 'kien/rainbow_parentheses.vim'
Bundle 'thinca/vim-prettyprint'
Bundle 'vim-scripts/Decho'
Bundle 'ack.vim'
Bundle 'The-NERD-tree'
Bundle 'notes.vim'
Bundle 'tpope/vim-foreplay'
Bundle 'tpope/vim-classpath'
Bundle 'guns/vim-clojure-static'
Bundle 'paredit.vim'
Bundle 'Gist.vim'
Bundle 'WebAPI.vim'
Bundle 'digitaltoad/vim-jade'
Bundle 'groenewege/vim-less'
Bundle 'scratch.vim'
Bundle 'copy-as-rtf'
Bundle 'bling/vim-airline'

filetype plugin indent on

" Airline configruation
let g:airline_theme='powerlineish'
let g:airline_powerline_fonts=1
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ''
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ''
let g:airline#extensions#tabline#left_alt_sep = ''


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

runtime localvimrc

"function GetFooText()
  "return localtime()
"endfunction

"call airline#parts#define_function('foo', 'GetFooText')

"function! AirlineInit()
"endfunction
  "let g:airline_section_y = airline#section#create(['foo', ' ', 'ffenc'])
"autocmd VimEnter * call AirlineInit()
