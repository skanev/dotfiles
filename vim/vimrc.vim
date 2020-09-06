syntax on
set nocompatible

let mapleader = ","

if has('nvim')
  set runtimepath^=~/.vim runtimepath+=~/.vim/after
end

" My 'early' stuff
runtime early/term.vim
runtime early/mapmeta.vim

" Pathogen and Vundle
filetype off
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()

" Bundles
call plug#begin('~/.vim/plugged')
Plug 'vim-scripts/vundle'
Plug 'tpope/vim-haml'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-cucumber'
"Plug 'scrooloose/syntastic'
Plug 'tpope/vim-rails'
Plug 'godlygeek/tabular'
Plug 'vim-ruby/vim-ruby'
Plug 'michaeljsmith/vim-indent-object'
Plug 'scrooloose/nerdcommenter'
Plug 'skanev/vim-nexus'
Plug 'ervandew/supertab'
Plug 'vim-scripts/extradite.vim'
Plug 'onemanstartup/vim-slim'
Plug 'altercation/vim-colors-solarized'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-endwise'
Plug 'kchmck/vim-coffee-script'
Plug 'kien/rainbow_parentheses.vim'
Plug 'thinca/vim-prettyprint'
Plug 'vim-scripts/Decho'
Plug 'mileszs/ack.vim'
Plug 'vim-scripts/The-NERD-tree'
Plug 'xolox/vim-misc'
Plug 'vim-scripts/notes.vim'
Plug 'tpope/vim-fireplace'
Plug 'tpope/vim-classpath'
Plug 'guns/vim-clojure-static'
Plug 'vim-scripts/paredit.vim'
Plug 'vim-scripts/Gist.vim'
Plug 'vim-scripts/WebAPI.vim'
Plug 'digitaltoad/vim-jade'
Plug 'groenewege/vim-less'
Plug 'vim-scripts/scratch.vim'
Plug 'bling/vim-airline'
Plug 'vim-scripts/go.vim'
Plug 'tpope/vim-fugitive'
Plug 'vim-scripts/Gundo'
Plug 'fatih/vim-go'
Plug 'AndrewRadev/switch.vim'
Plug 'AndrewRadev/sideways.vim'
Plug 'AndrewRadev/splitjoin.vim'
Plug 'vim-scripts/nginx.vim'
Plug 'mtscout6/vim-cjsx'
Plug 'tmux-plugins/vim-tmux'
Plug 'keith/swift.vim'
Plug 'dylnmc/synstack.vim'

Plug 'junegunn/fzf'
Plug 'dense-analysis/ale'
Plug 'majutsushi/tagbar'
Plug 'zackhsi/fzf-tags'

Plug 'sainnhe/sonokai'
Plug 'patstockwell/vim-monokai-tasty'

Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'
Plug 'jparise/vim-graphql'
Plug 'pangloss/vim-javascript'
Plug 'elzr/vim-json'
Plug 'jparise/vim-graphql'
Plug 'yuezk/vim-js'
Plug 'maxmellon/vim-jsx-pretty'

"Plug 'neoclide/coc.nvim', {'branch': 'release'}

if has('gui_macvim') && has('gui_running')
  Plug 'vim-scripts/copy-as-rtf'
endif

call plug#end()

filetype plugin indent on

let g:coc_global_extensions = [
  \ 'coc-tsserver'
  \ ]

let g:vim_json_syntax_conceal = 0

let g:splitjoin_split_mapping = ''
let g:splitjoin_join_mapping = ''

" Suppress DEcho's dependency's <Leader>s overriding
"nmap <unique> <Leader>SWP <Plug>SaveWinPosn
"nmap <unique> <Leader>RWP <Plug>RestoreWinPosn

nmap <Leader>j :SplitjoinJoin<CR>
nmap <Leader>s :SplitjoinSplit<CR>

nnoremap <C-h> :SidewaysLeft<CR>
nnoremap <C-l> :SidewaysRight<CR>

nnoremap - :Switch<CR>

if isdirectory(expand("~/.vim/plugged/vim-airline"))
  "  source ~/.vim/bundle/skanev/other/airline-theme.vim
endif

" fzf
let g:fzf_layout = { 'down': '~25%' }
let g:fzf_colors = {
\ 'bg+': ['bg', 'Visual']
\}

" the_silver_searcher
let g:ackprg = "ag --vimgrep"

" Airline configruation
" let g:airline_theme = 'skanev'
let g:airline#extensions#keymap#enabled = 0
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

" Ale
let g:ale_linters = {
\ "ruby": ["rubocop", "ruby"]
\}
let g:ale_fixers = {
\ "ruby": ["rubocop"]
\}
let g:ale_sign_error = "✘"
let g:ale_sign_warning = "●"
let g:ale_sign_info = "■"
let g:ale_sign_style_error = "✘"
let g:ale_sign_style_warning = "►"

let g:no_synstack_maps = 1

map [r :A<CR>
map ]r :R<CR>

autocmd BufEnter *.{js,jsx,ts,tsx} :syntax sync fromstart
autocmd BufLeave *.{js,jsx,ts,tsx} :syntax sync clear

function! PromoteToLet()
  s/\v(\w+)\s+\=\s+(.*)$/let(:\1) { \2 }/
  normal ==
endfunction

command! PromoteToLet :call PromoteToLet()
map <Leader>l :PromoteToLet<CR>

command! Reverse :g/^/m0

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

let NERDTreeIgnore=['node_modules$']

function! HTestDefine()
  let line = search('^\(module\|class\)')
  let command = 'map <D-r> :!tmux send-keys C-u C-l "rails runner " ' . split(getline(line), ' ')[1] . '.test C-m<CR><CR>'
  execute command
endfunction

command! HtestDefine :call HTestDefine()

runtime localvimrc

"function GetFooText()
  "return localtime()
"endfunction

"call airline#parts#define_function('foo', 'GetFooText')

"function! AirlineInit()
"endfunction
  "let g:airline_section_y = airline#section#create(['foo', ' ', 'ffenc'])
"autocmd VimEnter * call AirlineInit()

