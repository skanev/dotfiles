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
Plug 'vim-airline/vim-airline-themes'
Plug 'tpope/vim-fugitive'
Plug 'int3/vim-extradite'
Plug 'dense-analysis/ale'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'zackhsi/fzf-tags'
Plug 'majutsushi/tagbar'
if has('python3') | Plug 'SirVer/ultisnips' | endif
Plug 'dylnmc/synstack.vim'
Plug 'jlanzarotta/bufexplorer'

" Workflow
Plug 'tpope/vim-surround'
Plug 'tpope/vim-abolish'
Plug 'godlygeek/tabular'
Plug 'michaeljsmith/vim-indent-object'
Plug 'scrooloose/nerdcommenter'
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

" Temporary(?)
Plug 'voldikss/vim-floaterm'

" NVIM
if g:env.nvim
  Plug 'nanotee/nvim-lua-guide'
endif

" Completion
if g:env.nightly
  Plug 'neovim/nvim-lspconfig'
  Plug 'kabouzeid/nvim-lspinstall'
  Plug 'glepnir/lspsaga.nvim'

  Plug 'hrsh7th/vim-vsnip'
  Plug 'hrsh7th/vim-vsnip-integ'
  Plug 'hrsh7th/nvim-compe'

  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'nvim-treesitter/playground'
else
  Plug 'ervandew/supertab'
endif

if g:env.app == 'mvim'
  Plug 'vim-scripts/copy-as-rtf'
endif

if g:tweaks.devicons
  Plug 'ryanoasis/vim-devicons'
endif

" Someplugins that I used to know

"Plug 'neoclide/coc.nvim', {'branch': 'release'}
"Plug 'nvim-lua/completion-nvim'
"Plug 'Shougo/deoplete.nvim'
"Plug 'deoplete-plugins/deoplete-lsp'
"Plug 'digitaltoad/vim-jade'
"Plug 'tpope/vim-cucumber'
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

" tpope/vim-surround
let g:surround_no_insert_mappings = 1

" AndrewRadev/Switch.vim
let g:switch_mapping = ''
let g:switch_reverse_mapping = ''

" SirVer/ultisnips
let g:UltiSnipsSnippetDirectories=[g:dotfiles_dir.'/vim/snips']
let g:UltiSnipsExpandTrigger       = "<Tab>"
let g:UltiSnipsListSnippets        = ""
let g:UltiSnipsJumpForwardTrigger  = "<C-j>"
let g:UltiSnipsJumpBackwardTrigger = "<C-k>"
let g:UltiSnipsEditSplit           = "horizontal"

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
let g:fzf_layout = {'down': '~25%'}
let g:fzf_action = {
  \ '': 'SafeOpen',
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }

command! -nargs=* SafeOpen if &modified | botright split <args> | else | edit <args> | endif

let s:fzf_files_opts = {
\ 'window': {'width': 0.6, 'height': 0.6, 'relative': v:false},
\ 'options': ['--layout=reverse', '--info=inline'],
\}

function! s:fzf_ag_options()
  return fzf#vim#with_preview({
    \ 'window': {'width': 0.96, 'height': 0.7, 'relative': v:false},
    \ 'options': [
    \   '--layout=reverse',
    \   '--info=inline',
    \ ],
    \}, 'down:40%')
endfunction

function! s:fzf_buffers(fullscreen)
  call fzf#vim#buffers({
      \ 'window': {'width': 0.6, 'height': 0.6, 'relative': v:false},
      \ 'options': ['--layout=reverse', '--info=inline'],
      \}, a:fullscreen)
endfunction

command! -bang -nargs=? -complete=dir Files   call fzf#vim#files(<q-args>, copy(s:fzf_files_opts), <bang>0)
command! -bang                        Buffers call s:fzf_buffers(<bang>0)
command! -bang -nargs=*               Ag      call fzf#vim#ag(<q-args>, s:fzf_ag_options(), <bang>0)

" mileszs/ack.vim
let g:ackprg = "ag --vimgrep"

" vim-scripts/Gist.vim
let g:gist_clip_command = 'pbcopy'
let g:gist_open_browser_after_post = 1
let g:gist_post_private = 1

" dense-analysis/ale
let g:ale_linters_explicit = 1
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
let NERDTreeIgnore = ['node_modules$']
