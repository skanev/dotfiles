" Appearance
set ruler
set wildmenu
set number
set nowrap
set showcmd

set incsearch
set hlsearch

" Behavior
set autoindent
set autoread
set ignorecase
set smartcase
set scrolloff=5

set modeline

set backspace=indent,eol,start

" set wildignore+=**/tmp/**
set nojoinspaces

" System
set dir=~/.vim-backup

if has('persistent_undo')
  set undodir=~/.vim-undo
  set undofile
end

" Highlight invisible characters
set listchars=eol:¬,tab:→\ 

" Status line
set laststatus=2

" GUI settings
if has('gui_running')
  set guioptions-=T
  set guioptions-=m
  set guioptions-=e
  set guioptions-=r
  set guioptions-=L
  if has("gui_gtk2")
    set guifont=DejaVu\ Sans\ Mono\ for\ Powerline\ 10
    set linespace=2
  elseif has("gui_macvim")
    set guifont=Monaco\ for\ Powerline:h14
    set linespace=3
    set macmeta
  endif
else
  set t_Co=256
  set mouse=a
  if has('termguicolors')
    set termguicolors
  endif
end

" Colorscheme
if $VIM_COLORSCHEME != ""
  exec 'colorscheme '.$VIM_COLORSCHEME
elseif has('gui_gtk2')
  colorscheme native
elseif has('gui_running')
  let g:sonokai_style = 'shusia'
  colorscheme sonokai
  hi TabLineSel guibg=#7f6468 guifg=#ffffff
  hi VertSplit guifg=#e5c463
  hi Cursor guibg=#000000 guifg=#ffffff
  hi link rubySymbol Purple
  hi link rubyInterpolation White
  hi link rubyInterpolationDelimiter Orange
  hi link rubyModuleName rubyClassName
  hi link rubyMacro Orange
  hi link perlVarPlain Blue
  hi link perlVarPlain2 Blue
  hi link perlSpecialString perlString

  hi DimPurple guifg=#9d9ca0
  hi DimYellow guifg=#938a70
  hi DimOrange guifg=#9d8174
  hi DimRed guifg=#a67581
  hi DimWhite guifg=#adadad
  hi DimGreen guifg=#737b6b

  hi CocErrorHighlight cterm=underline gui=undercurl guisp=#f85e84
  hi CocWarningHighlight cterm=underline gui=undercurl guisp=#e5c463
  hi CocInfoHighlight cterm=underline gui=undercurl guisp=#7accd7
  hi CocHintHighlight cterm=underline gui=undercurl guisp=#9ecd6f

  hi link perlPOD DimWhite
  hi link podVerbatimLine DimGreen
  hi link podCommand DimRed
  hi link podCmdText DimYellow
  hi link podOverIndent DimPurple
  hi link podForKeywd DimOrange
  hi link podFormat DimOrange
  hi link podSpecial DimOrange
  hi link podEscape DimYellow
  hi link podEscape2 DimPurple
  hi link podBoldItalic DimWhite
  hi link podBoldOpen DimWhite
  hi link podBoldAlternativeDelimOpen DimWhite
  hi link podItalicBold DimWhite
  hi link podItalicOpen DimWhite
  hi link podItalicAlternativeDelimOpen DimWhite
  hi link podNoSpaceOpen DimWhite
  hi link podNoSpaceAlternativeDelimOpen DimWhite
  hi link podIndexOpen DimWhite
  hi link podIndexAlternativeDelimOpen DimWhite
  hi link podBold DimWhite
  hi link podBoldAlternativeDelim DimWhite
  hi link podItalic DimWhite
  hi link podItalicAlternativeDelim DimWhite

  "colorscheme vividchalk
elseif $ITERM_PROFILE == "Beamer"
  colorscheme emacs
else
  "colorscheme vim-monokai-tasty
  colorscheme vividchalk
end
