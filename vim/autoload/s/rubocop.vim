function! s#rubocop#current_line_offenses()
  if !exists('g:ale_enabled')
    return luaeval('vim.lsp.diagnostic.get_line_diagnostics()')->filter({_, v -> v.source == 'rubocop' })->map({_, v -> v.code})
  endif

  let line = line('.')
  let offences = []

  for item in getloclist('.')
    if item.lnum != line | continue | endif

    let name = matchstr(item.text, '^[^:]\+\ze:')

    if name != 'warning' && index(offences, name) == -1
      call add(offences, name)
    endif
  endfor

  return offences
endfunction

function! s#rubocop#help_url(offense)
  let [group, name] = split(a:offense, '/')

  let section = ""
  if group == 'RSpec'     | let section = 'rubocop-rspec'
  elseif group == 'Rails' | let section = 'rubocop-rails'
  else                    | let section = 'rubocop'
  endif

  return printf("https://docs.rubocop.org/%s/cops_%s.html#%s%s", section, tolower(group), tolower(group), tolower(name))
endfunction
