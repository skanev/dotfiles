set wildmenu     " fancy command completion menu
set number       " show line numbers
set nowrap       " don't wrap long lines
set showcmd      " shows number of selected lines/characters

set incsearch    " search immediatelly instead of waiting <CR>
set hlsearch     " highlight search results

set autoindent   " copy indentation from current line when starting a new one
set autoread     " automatically read changed files
set ignorecase   " case-insensitive search...
set smartcase    " ...unless pattern contains uppercase

set scrolloff=5  " scroll before cursor reach edges

set modeline     " evaluate modelines
set nojoinspaces " no double spacing on join, which year is it
set ttyfast      " don't assume slow terminals

set laststatus=2               " always have a status line
set belloff=all                " turn bells off
set updatetime=100             " helps gitgutter be faster
set nrformats-=octal           " C-a should not increment 07 to 10

set backspace=indent,eol,start " intuitive backspace
set dir=~/.vim-backup          " swap file location
set listchars=eol:¬,tab:→\     " invisible characters

set keymap=bulgarian-skanev    " my input method for Bulgarian
set iminsert=0                 " don't switch to BDS automatically
set imsearch=-1                " search in the same language as iserting

if has('persistent_undo')
  set undofile                 " have persistent undo
  set undodir=~/.vim-undo      " where are undo files stored
end

" Font
let s:themes = {
      \ 'gvim-wsl': ['Monospace Regular 12', 2],
      \ 'macvim':   ['Monaco for Powerline:h14', 2],
      \ 'winvim':   ['Consolas:h14', 3],
      \}

if g:env.term
  set t_Co=256
  set mouse=a
  if has('termguicolors')
    set termguicolors
  endif
else
  set guioptions-=T
  set guioptions-=m
  set guioptions-=e
  set guioptions-=r
  set guioptions-=L

  let [font, lineheight] = s:themes[g:env.profile]

  let &guifont = font
  let &linespace = lineheight
endif

" Colorscheme

if $VIM_COLORSCHEME != ""
  exec 'colorscheme '.$VIM_COLORSCHEME
elseif g:env.gui
  let g:sonokai_style = 'shusia'
  colorscheme sonokai
else
  colorscheme vividchalk
end
