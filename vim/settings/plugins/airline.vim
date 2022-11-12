" bling/vim-ariline
let g:airline_powerline_fonts = 1
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_branch_prefix= ''
let g:airline_readonly_symbol = ''
let g:airline_linecolumn_prefix = ''

let g:airline#extensions#keymap#enabled = 0
let g:airline#extensions#tagbar#enabled = 0
let g:airline#extensions#hunks#non_zero_only = 1
let g:airline#extensions#hunks#enabled = g:gitgutter_enabled

function! AirlineInSnippet()
  if g:tweaks.devicons
    return 'SNIP '
  else
    return 'SNIP'
  end
endfunction

function! AirlineInContext()
  if g:tweaks.devicons
    return b:context . ' '
  else
    return b:context
  end
endfunction

augroup airline_ultisnips
  autocmd!
  autocmd  User UltiSnipsEnterFirstSnippet let b:airline_in_ultisnips = 1
  autocmd  User UltiSnipsExitLastSnippet   let b:airline_in_ultisnips = 0
augroup END

call airline#parts#define_function('snip', 'AirlineInSnippet')
call airline#parts#define_condition('snip', 'get(b:, "airline_in_ultisnips", 0)')

call airline#parts#define_function('context', 'AirlineInContext')
call airline#parts#define_condition('context', 'get(b:, "context", "") != ""')

let g:airline_section_x = airline#section#create_right(['context', 'snip', 'filetype'])
