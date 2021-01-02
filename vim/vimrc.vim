syntax on
set nocompatible
let mapleader = ","

" My 'early' stuff
runtime bundle/skanev/early/term.vim
runtime bundle/skanev/early/mapmeta.vim

" Pathogen and Vundle
filetype off
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()

" Bundles
call plug#begin('~/.vim/plugged')
Plug 'vundle'
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
Plug 'mileszs/ack.vim'
Plug 'The-NERD-tree'
Plug 'xolox/vim-misc'
Plug 'notes.vim'
Plug 'tpope/vim-fireplace'
Plug 'tpope/vim-classpath'
Plug 'tpope/vim-repeat'
Plug 'guns/vim-clojure-static'
Plug 'paredit.vim'
Plug 'Gist.vim'
Plug 'WebAPI.vim'
Plug 'digitaltoad/vim-jade'
Plug 'groenewege/vim-less'
Plug 'scratch.vim'
Plug 'bling/vim-airline'
Plug 'go.vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'Gundo'
Plug 'fatih/vim-go'
Plug 'AndrewRadev/switch.vim'
Plug 'AndrewRadev/sideways.vim'
Plug 'AndrewRadev/splitjoin.vim'
Plug 'nginx.vim'
Plug 'mtscout6/vim-cjsx'
Plug 'tmux-plugins/vim-tmux'
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'
Plug 'jparise/vim-graphql'
Plug 'elzr/vim-json'

"Plug 'sheerun/vim-polyglot'

if has('gui_macvim')
  Plug 'copy-as-rtf'
endif

call plug#end()

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

if isdirectory(expand("~/.vim/plugged/vim-airline"))
  source ~/.vim/bundle/skanev/other/airline-theme.vim
endif

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

" Disable netrw
" let g:loaded_netrw = 1
" let g:loaded_netrwPlugin = 1

" Gist
let g:gist_clip_command = 'pbcopy'
let g:gist_open_browser_after_post = 1
let g:gist_post_private = 1

" Syntastic
let g:syntastic_enable_signs=1

" CtlrP
let g:ctrlp_custom_ignore = {
  \ 'dir': '\v(plugged|vim-backup|vim-undo)|([\/]\.(git|hg|svn)$)',
  \ }
let g:ctrlp_working_path_mode = 'ra'

" Ack
if executable('ag')
  let g:ackprg = 'ag --vimgrep'
endif

map [f :A<CR>
map ]f :R<CR>

function! PromoteToLet()
  s/\v(\w+)\s+\=\s+(.*)$/let(:\1) { \2 }/
  normal ==
endfunction
command! PromoteToLet :call PromoteToLet()
map <Leader>l :PromoteToLet<CR>

command! Reverse :g/^/m0
command! ReverseQuickFixList :call setqflist(reverse(getqflist()))

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

"set keymap=bulgarian-skanev
set iminsert=0
set imsearch=-1
cnoremap <C-c> <C-^>
inoremap <C-c> <C-^>

" Syntastic is far too slow for SCSS
let g:syntastic_scss_checkers = []
let g:syntastic_slim_checkers = []

runtime localvimrc

vmap gb <Plug>NexusSendSelection()<CR>

let g:ackprg = 'ag --vimgrep'

set textwidth=100 " maybe make this per file type at some point
"function GetFooText()
  "return localtime()
"endfunction

"call airline#parts#define_function('foo', 'GetFooText')

"function! AirlineInit()
"endfunction
  "let g:airline_section_y = airline#section#create(['foo', ' ', 'ffenc'])
"autocmd VimEnter * call AirlineInit()
