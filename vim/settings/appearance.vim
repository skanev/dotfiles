let s:themes = [
  \ ['mvim',     '*',   {'font': 'Monaco for Powerline:h14', 'line': 2                        }],
  \
  \ ['vim',      '*',   {                                               'scheme': 'vividchalk'}],
  \ ['nvim',     '*',   {                                               'scheme': 'vividchalk'}],
  \
  \ ['fvim',     '*',   {'font': 'Fira Code:h16',            'line': 3                        }],
  \ ['neovide',  '*',   {'font': 'Fira Code:h16',            'line': 0                        }],
  \ ['goneovim', '*',   {'font': 'Fira Code:h16',            'line': 3                        }],
  \
  \ ['winvim',   '*',   {'font': 'Consolas:h14',             'line': 3                        }],
  \
  \ ['*',        '*',   {'font': 'Iosevka Extended 12',      'line': 2, 'scheme': 'sonokai'   }]
  \ ]

let g:sonokai_style = 'shusia'

let s:font        = ''
let s:linespace   = -1
let s:colorscheme = $VIM_COLORS != '' ? $VIM_COLORS : ''

function! s:satisfies(target, actual)
  return a:target == '*' || a:target == a:actual
endfunction

for [app, os, opts] in s:themes
  if !s:satisfies(app, g:env.app) || !s:satisfies(os, g:env.os) | continue | endif

  if s:font == ''        && has_key(opts, 'font')   | let s:font = opts.font          | endif
  if s:linespace == -1   && has_key(opts, 'line')   | let s:linespace = opts.line     | end
  if s:colorscheme == '' && has_key(opts, 'scheme') | let s:colorscheme = opts.scheme | endif
endfor

if s:font != ''        | let &guifont = s:font                  | endif
if s:colorscheme != '' | execute "colorscheme " . s:colorscheme | endif
if s:linespace != -1   | let &linespace = s:linespace           | endif
