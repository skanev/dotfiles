let helper = {}

function! helper.starts_with(longer, shorter) dict abort
  return a:longer[0:len(a:shorter)-1] ==# a:shorter
endfunction

function! helper.capture_vim_command(command) dict abort
  let saved_p = @p

  try
    redir @p
    execute "silent" a:command
    redir END

    let result = @p
    return result
  finally
    let @p = saved_p
  endtry
endfunction

function! helper.functions(pattern) dict abort
  return self.capture_vim_command('function')
        \ ->split("\n")
        \ ->map({ _, line -> line->matchstr('^function \zs[^(]*\ze(') })
        \ ->filter({ _, line -> line->match(a:pattern) >= 0 })
endfunction

" Returns a Dict of all loaded scripts, { sid : filename }
function! helper.scripts() dict abort
  let result = {}

  for line in split(self.capture_vim_command('scriptnames'), "\n")
    let groups = matchlist(line, '^\s*\(\d\+\):\s*\(\S\+\)')
    if groups == [] | continue | endif

    let file = expand(groups[2], ':p')
    if !self.starts_with(file, g:dotfiles_dir) || self.starts_with(file, g:dotfiles_dir . "/vim/bundles/") | continue | endif

    let result[groups[1]] = groups[2]
  endfor

  return result
endfunction

" Returns a Dict whose keys are the s: functions in the script that matches
" the pattern.
"
" Useful for unit-testing internals.
function! helper.script_functions(pattern) dict abort
  let matches = self.scripts()->filter({ key, value -> value->match(a:pattern) >= 0 })->items()

  if matches->len() == 0
    throw "Didn't find a script matching: " . a:pattern
  elseif matches->len() >= 2
    throw "Found multiple scripts matching: " . a:pattern
  else
    let [sid, _] = matches[0]
    let fn_pattern = '^<SNR>' . sid . '_\zs.*'
    let result = {}
    for full_name in self.functions(fn_pattern)
      let short_name = full_name->matchstr(fn_pattern)
      let result[short_name] = function(full_name)
    endfor
    return result
  endif
endfunction

let g:helper = helper
