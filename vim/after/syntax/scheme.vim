highlight level1c ctermfg=brown guifg=RoyalBlue3
highlight level2c ctermfg=Darkblue guifg=SeaGreen3
highlight level3c ctermfg=darkgray guifg=DarkOrchid3
highlight level4c ctermfg=darkgreen guifg=firebrick3
highlight level5c ctermfg=darkcyan guifg=RoyalBlue3
highlight level6c ctermfg=darkred guifg=SeaGreen3
highlight level7c ctermfg=darkmagenta guifg=DarkOrchid3
highlight level8c ctermfg=brown guifg=firebrick3
highlight level9c ctermfg=gray guifg=RoyalBlue3
highlight level10c ctermfg=black guifg=SeaGreen3
highlight level11c ctermfg=darkmagenta guifg=DarkOrchid3
highlight level12c ctermfg=Darkblue guifg=firebrick3
highlight level13c ctermfg=darkgreen guifg=RoyalBlue3
highlight level14c ctermfg=darkcyan guifg=SeaGreen3
highlight level15c ctermfg=darkred guifg=DarkOrchid3
highlight level16c ctermfg=red guifg=firebrick3

syntax region level1 matchgroup=level1c start=/(/ end=/)/ contains=TOP,level1,level2,level3,level4,level5,level6,level7,level8,level9,level10,level11,level12,level13,level14,level15, level16,NoInParens
syntax region level2 matchgroup=level2c start=/(/ end=/)/ contains=TOP,level2,level3,level4,level5,level6,level7,level8,level9,level10,level11,level12,level13,level14,level15, level16,NoInParens
syntax region level3 matchgroup=level3c start=/(/ end=/)/ contains=TOP,level3,level4,level5,level6,level7,level8,level9,level10,level11,level12,level13,level14,level15, level16,NoInParens
syntax region level4 matchgroup=level4c start=/(/ end=/)/ contains=TOP,level4,level5,level6,level7,level8,level9,level10,level11,level12,level13,level14,level15, level16,NoInParens
syntax region level5 matchgroup=level5c start=/(/ end=/)/ contains=TOP,level5,level6,level7,level8,level9,level10,level11,level12,level13,level14,level15, level16,NoInParens
syntax region level6 matchgroup=level6c start=/(/ end=/)/ contains=TOP,level6,level7,level8,level9,level10,level11,level12,level13,level14,level15, level16,NoInParens
syntax region level7 matchgroup=level7c start=/(/ end=/)/ contains=TOP,level7,level8,level9,level10,level11,level12,level13,level14,level15, level16,NoInParens
syntax region level8 matchgroup=level8c start=/(/ end=/)/ contains=TOP,level8,level9,level10,level11,level12,level13,level14,level15, level16,NoInParens
syntax region level9 matchgroup=level9c start=/(/ end=/)/ contains=TOP,level9,level10,level11,level12,level13,level14,level15, level16,NoInParens
syntax region level10 matchgroup=level10c start=/(/ end=/)/ contains=TOP,level10,level11,level12,level13,level14,level15, level16,NoInParens
syntax region level11 matchgroup=level11c start=/(/ end=/)/ contains=TOP,level11,level12,level13,level14,level15, level16,NoInParens
syntax region level12 matchgroup=level12c start=/(/ end=/)/ contains=TOP,level12,level13,level14,level15, level16,NoInParens
syntax region level13 matchgroup=level13c start=/(/ end=/)/ contains=TOP,level13,level14,level15, level16,NoInParens
syntax region level14 matchgroup=level14c start=/(/ end=/)/ contains=TOP,level14,level15, level16,NoInParens
syntax region level15 matchgroup=level15c start=/(/ end=/)/ contains=TOP,level15, level16,NoInParens
syntax region level16 matchgroup=level16c start=/(/ end=/)/ contains=TOP,level16,NoInParens
