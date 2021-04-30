syntax on
set nocompatible

set updatetime=100
set ttyfast

let mapleader = ","

let g:dotfiles_dir = expand('<sfile>:p:h:h')

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
Plug 'tpope/vim-rails'
Plug 'godlygeek/tabular'
Plug 'vim-ruby/vim-ruby'
Plug 'michaeljsmith/vim-indent-object'
Plug 'scrooloose/nerdcommenter'
Plug 'ervandew/supertab'
Plug 'int3/vim-extradite'
Plug 'onemanstartup/vim-slim'
Plug 'altercation/vim-colors-solarized'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-endwise'
Plug 'kchmck/vim-coffee-script'
Plug 'mileszs/ack.vim'
Plug 'vim-scripts/The-NERD-tree'
Plug 'vim-scripts/paredit.vim'
Plug 'vim-scripts/Gist.vim'
Plug 'vim-scripts/WebAPI.vim'
Plug 'vim-scripts/scratch.vim'
Plug 'bling/vim-airline'
Plug 'tpope/vim-fugitive'
Plug 'vim-scripts/Gundo'
Plug 'AndrewRadev/switch.vim'
Plug 'AndrewRadev/sideways.vim'
Plug 'AndrewRadev/splitjoin.vim'
Plug 'AndrewRadev/linediff.vim'
Plug 'vim-scripts/nginx.vim'
Plug 'mtscout6/vim-cjsx'
Plug 'tmux-plugins/vim-tmux'
Plug 'keith/swift.vim'
Plug 'dylnmc/synstack.vim'
Plug 'airblade/vim-gitgutter'
Plug 'chrisbra/vim-zsh'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'dense-analysis/ale'
Plug 'majutsushi/tagbar'
Plug 'zackhsi/fzf-tags'
Plug 'SirVer/ultisnips'
Plug 'sainnhe/sonokai'
Plug 'vim-perl/vim-perl', {'for': 'perl', 'do': 'make clean carp dancer highlight-all-pragmas moose test-more try-tiny'}
Plug 'vim-crystal/vim-crystal'

" JavaScript plugins that I just keep here
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'
Plug 'jparise/vim-graphql'
Plug 'pangloss/vim-javascript'
Plug 'elzr/vim-json'
Plug 'jparise/vim-graphql'
Plug 'yuezk/vim-js'
Plug 'maxmellon/vim-jsx-pretty'

" Someplugins that I used to know
"Plug 'digitaltoad/vim-jade'
"Plug 'tpope/vim-cucumber'
"Plug 'neoclide/coc.nvim', {'branch': 'release'}
"Plug 'francoiscabrol/ranger.vim'
"Plug 'vim-scripts/Decho'
"Plug 'kien/rainbow_parentheses.vim'
"Plug 'thinca/vim-prettyprint'
"Plug 'xolox/vim-misc'
"Plug 'vim-scripts/notes.vim'
"Plug 'tpope/vim-fireplace'
"Plug 'tpope/vim-classpath'
"Plug 'guns/vim-clojure-static'
"Plug 'groenewege/vim-less'
"Plug 'vim-scripts/go.vim'
"Plug 'fatih/vim-go'

if has('gui_macvim') && has('gui_running')
  Plug 'vim-scripts/copy-as-rtf'
endif

call plug#end()

filetype plugin indent on

let g:UltiSnipsSnippetDirectories=[$HOME.'/.vim/snips']
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
let g:UltiSnipsEditSplit="horizontal"

let g:coc_global_extensions = [
  \ 'coc-tsserver'
  \ ]

let g:gitgutter_map_keys = 0
let g:gitgutter_enabled = 1
let g:airline#extensions#hunks#non_zero_only = 1
let g:airline#extensions#hunks#enabled = g:gitgutter_enabled

nmap [c <Plug>(GitGutterPrevHunk)
nmap ]c <Plug>(GitGutterNextHunk)
nmap <silent> <expr> yog <SID>ToggleGitGutter()

function! s:ToggleGitGutter()
  GitGutterToggle
  let g:airline#extensions#hunks#enabled = 1
  AirlineRefresh
endfunction

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
let g:airline_powerline_fonts = 1
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_branch_prefix= ''
let g:airline_readonly_symbol = ''
let g:airline_linecolumn_prefix = ''

let g:airline#extensions#keymap#enabled = 0
let g:airline#extensions#tagbar#enabled = 0
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
\ "ruby": ["rubocop", "ruby"],
\ "perl": ["perl"]
\}
let g:ale_fixers = {
\ "ruby": ["rubocop"]
\}

" Include the Swamp (ALE copies the file to /tmp, so lib::relative stops working ;/)
let g:ale_perl_perl_options="-c -Mwarnings -Ilib -I" . g:dotfiles_dir . "/support/perl/lib"

let g:ale_sign_error = "✘"
let g:ale_sign_warning = "●"
let g:ale_sign_info = "■"
let g:ale_sign_style_error = "✘"
let g:ale_sign_style_warning = "►"

let g:ale_lint_on_text_changed = 0
let g:ale_lint_on_insert_leave = 0
let g:ale_lint_on_enter = 1
let g:ale_lint_on_save = 1
let g:ale_lint_on_filetype_changed = 1

let g:ale_set_balloons = 1

let g:ale_ruby_rubocop_executable = 'bundle'

" synstack
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

command! Snips UltiSnipsEdit

map <expr> g= ':Tabularize /\V' . expand('<cWORD>') . '<CR>'

function! CreatePlayground()
  edit ~/Desktop/playground.rb
  map <buffer> Q :w!<CR>:!ruby % 2>&1 \| perl -pe 's/\e\[?.*?[\@-~]//g'<CR>

  if line('$') == 1 && getline('.') == ''
    let template =<< trim END
      class Solution
        def solve()
        end
      end

      def check(*args, expected)
        actual = Solution.new.solve(*args)
        if expected != actual
          puts "solve(#{args.map(&:inspect) * ', '}) = #{actual.inspect}, but expected #{expected.inspect}"
        end
      end

      check
    END

    call append(0, template)
    $delete _
  endif
endfunction

command! Playground :call CreatePlayground()

function! MapQToRerun()
  map <buffer> Q :w<CR>:!tmux send-keys C-e C-u C-l C-p C-m<CR><CR>
endfunction
command! MapQToRerun :call MapQToRerun()

cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h') . '/' : '%%'

runtime localvimrc
