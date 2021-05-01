if exists("b:current_syntax")
  finish
endif

syntax clear

" Clojure wants this:
" setlocal iskeyword+=?,-,*,!,+,/,=,<,>,.,:,$
" HTML wants this
" setlocal iskeyword-=<,>,/,=
" Here's the compromise:
setlocal iskeyword+=?,-,*,!,+,.,:,$

syntax region lectureHeading start=/^=/ end="$"
syntax match lectureListItemBullet /^[+*]/

syntax region lectureLinkText matchgroup=lectureLinkDelimiter start=/\[/ end=/\]\((\)\@=/ oneline nextgroup=lectureLinkUrl
syntax region lectureLinkUrl matchgroup=lectureLinkDelimiter start=/(/ end=/)/ contained
syntax region lectureLinkSingle matchgroup=lectureLinkDelimiter start=/\[/ end=/\]\((\)\@!/ oneline

syntax include @Clojure syntax/clojure.vim
unlet! b:current_syntax
syntax region clojureCode matchgroup=lectureDirective start=/^:\(annotate\|code\)$/ skip=/^\s*$/ end=/^\(  \)\@!/ contains=@Clojure
syntax region clojureCode matchgroup=lectureDirective start=/`/ matchgroup=lectureDirective end=/`/ contains=@Clojure
syntax region clojureSexp matchgroup=clojureParen start="("  matchgroup=clojureParen end=")" contains=@Clojure,@Spell contained
syntax region clojureVector matchgroup=clojureParen start="\[" matchgroup=clojureParen end="]" contains=@Clojure,@Spell contained
syntax region clojureMap matchgroup=clojureParen start="{"  matchgroup=clojureParen end="}" contains=@Clojure,@Spell contained

let main_syntax = 'lecture'
syntax include @HTML syntax/html.vim
unlet! b:current_syntax
syntax region htmlCode matchgroup=lectureDirective start=/{{{/ end=/}}}/ contains=@HTML

hi def link lectureHeading        Statement
hi def link lectureListItemBullet Keyword
hi def link lectureDirective      PreProc
hi def link lectureLinkText       Underlined
hi def link lectureLinkUrl        Constant
hi def link lectureLinkSingle     Constant

let b:current_syntax = "lecture"
