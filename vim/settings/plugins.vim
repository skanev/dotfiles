" VIM itself
Plug 'tpope/vim-scriptease'
Plug 'junegunn/vim-plug'

" Languages
Plug 'vim-ruby/vim-ruby'
Plug 'tpope/vim-rails'
Plug 'tpope/vim-haml'
Plug 'onemanstartup/vim-slim'
Plug 'kchmck/vim-coffee-script'
Plug 'mtscout6/vim-cjsx'
Plug 'tmux-plugins/vim-tmux'
Plug 'keith/swift.vim'
Plug 'vim-perl/vim-perl', {'for': 'perl', 'do': 'make clean carp dancer highlight-all-pragmas moose test-more try-tiny'}
Plug 'vim-crystal/vim-crystal'
Plug 'yuezk/vim-js'
Plug 'maxmellon/vim-jsx-pretty'
Plug 'elzr/vim-json'
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'
Plug 'jparise/vim-graphql'
Plug 'vim-scripts/nginx.vim'
Plug 'chrisbra/vim-zsh'

" Features
Plug 'preservim/nerdtree'
Plug 'vim-scripts/Gundo'
Plug 'airblade/vim-gitgutter'
Plug 'bling/vim-airline'
Plug 'tpope/vim-fugitive'
Plug 'int3/vim-extradite'
Plug 'dense-analysis/ale'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'zackhsi/fzf-tags'
Plug 'majutsushi/tagbar'
Plug 'SirVer/ultisnips'
Plug 'dylnmc/synstack.vim'
Plug 'jlanzarotta/bufexplorer'

" Workflow
Plug 'tpope/vim-surround'
Plug 'godlygeek/tabular'
Plug 'michaeljsmith/vim-indent-object'
Plug 'scrooloose/nerdcommenter'
Plug 'ervandew/supertab'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-endwise'
Plug 'mileszs/ack.vim'
Plug 'vim-scripts/paredit.vim'
Plug 'AndrewRadev/switch.vim'
Plug 'AndrewRadev/sideways.vim'
Plug 'AndrewRadev/splitjoin.vim'
Plug 'AndrewRadev/linediff.vim'

" Colorschemes
Plug 'sainnhe/sonokai'
Plug 'nanotech/jellybeans.vim'
Plug 'jonathanfilip/vim-lucius'
Plug 'morhetz/gruvbox'
Plug 'mhartington/oceanic-next'
Plug 'tpope/vim-vividchalk'

" Other
Plug 'vim-scripts/Gist.vim'
Plug 'vim-scripts/WebAPI.vim'
Plug 'vim-scripts/scratch.vim'

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

if g:env.kind == 'macvim'
  Plug 'vim-scripts/copy-as-rtf'
endif

" SirVer/ultisnips
let g:UltiSnipsSnippetDirectories=[$HOME.'/.vim/snips']
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
let g:UltiSnipsEditSplit="horizontal"

" airblade/vim-gitgutter
let g:gitgutter_map_keys = 0
let g:gitgutter_enabled = 1

" bling/vim-ariline
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
let g:airline#extensions#hunks#non_zero_only = 1
let g:airline#extensions#hunks#enabled = g:gitgutter_enabled

let g:vim_json_syntax_conceal = 0

let g:splitjoin_split_mapping = ''
let g:splitjoin_join_mapping = ''

" junegunn/fzf
let g:fzf_layout = { 'down': '~25%' }
let g:fzf_colors = {
\ 'bg+': ['bg', 'Visual']
\}

" mileszs/ack.vim
let g:ackprg = "ag --vimgrep"

" vim-scripts/Gist.vim
let g:gist_clip_command = 'pbcopy'
let g:gist_open_browser_after_post = 1
let g:gist_post_private = 1

" dense-analysis/ale
let g:ale_linters = {
\ "ruby": ["rubocop", "ruby"],
\ "perl": ["perl"]
\}

let g:ale_fixers = {
\ "ruby": ["rubocop"]
\}

let g:ale_perl_perl_options="-c -Mwarnings -Ilib -I" . g:dotfiles_dir . "/support/perl/lib" " Include the Swamp (ALE copies the file to /tmp, so lib::relative stops working ;/)

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

" dylnmc/synstack
let g:no_synstack_maps = 1

" preservim/nerdtree
let NERDTreeIgnore=['node_modules$']
