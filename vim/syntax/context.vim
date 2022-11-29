syntax clear

syntax include @Vimscript syntax/vim.vim
unlet b:current_syntax

syntax include @Zsh syntax/zsh.vim
unlet b:current_syntax

syntax region contextVim matchgroup=contextPragma start=/^@@vim\(\.\(folder\|buffer\)\)\?/ matchgroup=contextPragma end=/^@@end/ keepend contains=@Vimscript
syntax region contextZsh matchgroup=contextPragma start=/^@@\(mux\|zsh\)/ matchgroup=contextPragma end=/^@@end/ keepend contains=@Zsh

syntax match contextDetect /^@@detect/ nextgroup=contextDetectPath skipwhite
syntax match contextDetectPath /\S\+/ contained

highlight link contextPragma Title
highlight link contextDetect contextPragma
highlight link contextDetectPath String
