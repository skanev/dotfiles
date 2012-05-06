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
filetype plugin indent on

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
Bundle 'Lokaltog/vim-powerline'
Bundle 'kien/rainbow_parentheses.vim'
Bundle 'thinca/vim-prettyprint'
Bundle 'vim-scripts/Decho'

" Disable netrw
let g:loaded_netrw = 1
let g:loaded_netrwPlugin = 1

map [f :A<CR>
map ]f :R<CR>

call Pl#Theme#InsertSegment('nexus:status', 'after', 'scrollpercent')
