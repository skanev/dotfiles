syntax match  nestedMarkdownExp /\\\w\+/ contained
syntax match  nestedMarkdownExp '[=_/><!+-]' contained
syntax match  nestedMarkdownExp '\\\\' contained
syntax region nestedMarkdown    start="\$"   end="\$"    contains=nestedMarkdownExp
syntax region nestedMarkdown    start="\$\$" end="\$\$" contains=nestedMarkdownExp

highlight link nestedMarkdown    Special
highlight link nestedMarkdownExp Keyword

