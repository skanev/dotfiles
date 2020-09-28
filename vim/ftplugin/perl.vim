" vim:foldmethod=marker
" TODO: The path below should not be hardcoded
" (this needs to be here because vim-perl clobbers it on reopneing a file)
exec "setlocal path+=" . g:dotfiles_dir . "/support/perl/lib"

if (exists("b:did_skanev_ftplugin"))
  finish
endif
let b:did_skanev_ftplugin = 1

imap <buffer> <C-l> <Space>=><Space>
imap <buffer> <C-j> ->
nmap <buffer> K :call <SID>ShowHelp()<CR>

setlocal complete-=i
setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
set completefunc=PerlUserCompletion

"{{{ Show Help Function

function! s:ShowHelp()
  let word = expand('<cword>')

  if word =~ '\v\C^[a-z]'
    execute "terminal ++close ++shell perldoc -f " . word . ' || read -q'
  else
    execute "terminal ++close ++shell perldoc " . word . ' || read -q'
  endif
endfunction

"}}}

"{{{ Completion Function and friends

fun! PerlUserCompletion(findstart, base)
  if a:findstart
    let line = getline('.')
    let start = col('.') - 1
    while start > 0 && line[start - 1] =~ '\k'
      let start -= 1
    endwhile
    return start
  else
    let words_on_line = getline('.')->s#matches('\k\+')->s#without([a:base])
    return s:FindImports()->filter({_, m -> m =~ '^' . a:base})->s#without(words_on_line)
  endif
endfun

fun! s:FindImports()
  if search('^use \zs\k\+ qw(', 'bW') <= 0
    return []
  endif

  let prev = @"
  normal! ye
  let module = @"
  let @" = prev
  let filepath = module->split('::')->join('/') . '.pm'
  for pref in split(&path, ',')
    if pref == '' | continue | endif

    let filename = pref . '/' . filepath

    if filereadable(filename)
      let contents = readfile(filename)->join("\n")
      let export_lines = s#matches(contents, '@EXPORT\(_OK\)\?\s*=\s*\zs\_[^;]\+\ze;')
      let words = export_lines->s#flatmap({line -> line->s#matches('\k\+')})->filter({_, w -> w != 'qw'})

      return words
    endif
  endfor
endf

"}}}
