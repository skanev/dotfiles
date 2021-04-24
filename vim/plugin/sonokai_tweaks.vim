function! s:FixSonokai()
  highlight! TabLineSel guibg=#7f6468 guifg=#ffffff
  highlight! VertSplit guifg=#e5c463
  highlight! Cursor guibg=#000000 guifg=#ffffff
  highlight! link rubySymbol Purple
  highlight! link rubyInterpolation White
  highlight! link rubyInterpolationDelimiter Orange
  highlight! link rubyModuleName rubyClassName
  highlight! link rubyMacro Orange
  highlight! link perlVar Blue
  highlight! link perlVarPlain Blue
  highlight! link perlVarPlain2 Blue
  highlight! link perlSpecialString perlString

  highlight! DimPurple guifg=#9d9ca0
  highlight! DimYellow guifg=#938a70
  highlight! DimOrange guifg=#9d8174
  highlight! DimRed guifg=#a67581
  highlight! DimWhite guifg=#adadad
  highlight! DimGreen guifg=#737b6b

  highlight! CocErrorHighlight cterm=underline gui=undercurl guisp=#f85e84
  highlight! CocWarningHighlight cterm=underline gui=undercurl guisp=#e5c463
  highlight! CocInfoHighlight cterm=underline gui=undercurl guisp=#7accd7
  highlight! CocHintHighlight cterm=underline gui=undercurl guisp=#9ecd6f

  highlight! link perlPOD DimWhite
  highlight! link podVerbatimLine DimGreen
  highlight! link podCommand DimRed
  highlight! link podCmdText DimYellow
  highlight! link podOverIndent DimPurple
  highlight! link podForKeywd DimOrange
  highlight! link podFormat DimOrange
  highlight! link podSpecial DimOrange
  highlight! link podEscape DimYellow
  highlight! link podEscape2 DimPurple
  highlight! link podBoldItalic DimWhite
  highlight! link podBoldOpen DimWhite
  highlight! link podBoldAlternativeDelimOpen DimWhite
  highlight! link podItalicBold DimWhite
  highlight! link podItalicOpen DimWhite
  highlight! link podItalicAlternativeDelimOpen DimWhite
  highlight! link podNoSpaceOpen DimWhite
  highlight! link podNoSpaceAlternativeDelimOpen DimWhite
  highlight! link podIndexOpen DimWhite
  highlight! link podIndexAlternativeDelimOpen DimWhite
  highlight! link podBold DimWhite
  highlight! link podBoldAlternativeDelim DimWhite
  highlight! link podItalic DimWhite
  highlight! link podItalicAlternativeDelim DimWhite
endfunction

autocmd! ColorScheme sonokai call s:FixSonokai()
