" Vim color file
" Maintainer:	Stefan Kanev
"
" The default color scheme, slightly modified
hi clear Normal
set background=dark

" Remove all existing highlighting and set the defaults.
hi clear

" Load the syntax highlighting defaults, if it's enabled.
if exists("syntax_on")
	syntax reset
endif

let colors_name = "modified_default"
highlight Comment ctermfg=2
highlight SpecialKey ctermfg=0
highlight NonText ctermfg=0
highlight helpBar term=bold ctermfg=7
highlight helpStar term=bold ctermfg=6
" vim: sw=2
