let s:themes = [
  \ ['mvim',     '*',   {'font': 'Monaco for Powerline:h14',    'line': 2                                              }],
  \
  \ ['vim',      '*',   {                                                  'scheme': 'vividchalk', 'airline': 'murmur' }],
  \ ['nvim',     '*',   {                                                  'scheme': 'vividchalk', 'airline': 'murmur' }],
  \
  \ ['fvim',     '*',   {'font': 'Fira Code:h16',               'line': 3                                              }],
  \ ['neovide',  'mac', {'font': 'Iosevka Extended:h16',        'line': 0                                              }],
  \ ['neovide',  '*',   {'font': 'FiraCode Nerd Font:h16',      'line': 0                                              }],
  \ ['nvim-qt',  'mac', {'font': 'FiraCode Nerd Font Mono:h15', 'line': 2                                              }],
  \ ['nvim-qt',  '*',   {'font': 'Fira Code:h16',               'line': 2                                              }],
  \ ['goneovim', '*',   {'font': 'FiraCode Nerd Font Mono:h16', 'line': 0                                              }],
  \
  \ ['winvim',   '*',   {'font': 'Iosevka Extended:h12',        'line': 3, 'scheme': 'OceanicNext'                     }],
  \
  \ ['*',        '*',   {                                                  'scheme': 'sonokai'                         }]
  \ ]

let g:sonokai_style = 'shusia'
let g:appearance = {}

let s:font        = ''
let s:linespace   = -1
let s:colorscheme = $VIM_COLORS != '' ? $VIM_COLORS : ''
let s:airline     = ''

function! s:satisfies(target, actual)
  return a:target == '*' || a:target == a:actual
endfunction

function! s:set_font(font)
  if g:env.app == 'vimr' | return
  else                   | let &guifont = a:font
  endif

  let g:appearance.font = a:font
endfunction

function! s:set_linespace(linespace)
  if g:env.app == 'vimr' | return
  else                   | let &linespace = a:linespace
  endif
endfunction

for [app, os, opts] in s:themes
  if !s:satisfies(app, g:env.app) || !s:satisfies(os, g:env.os) | continue | endif

  if s:font == ''        && has_key(opts, 'font')    | let s:font = opts.font          | endif
  if s:linespace == -1   && has_key(opts, 'line')    | let s:linespace = opts.line     | end
  if s:colorscheme == '' && has_key(opts, 'scheme')  | let s:colorscheme = opts.scheme | endif
  if s:airline == ''     && has_key(opts, 'airline') | let s:airline = opts.airline    | endif
endfor

if s:font != ''        | call s:set_font(s:font)                | endif
if s:colorscheme != '' | execute "colorscheme " . s:colorscheme | endif
if s:linespace != -1   | call s:set_linespace(s:linespace)      | endif
if s:airline != ''     | let g:airline_theme = s:airline        | endif
