function! s:explain(cmd, match, pattern, opts)
  let old_a = @a

  redir! @a
  execute "silent " . a:cmd
  redir END

  let lines = split(@a, "\n")
  let @a = old_a

  call filter(lines, "match(v:val, a:match) != -1")

  let file = tempname()
  call writefile(lines, file)

  let opts = copy(a:opts)
  call map(opts, 'shellescape(v:val)')

  let cmd = printf('~/.scripts/explain-vim-keys %s %s %s', shellescape(a:pattern), file, join(opts, ' '))
  call s#popup(cmd, {'width': 75})
endfunction

command! ExplainLeader           call s:explain('nmap '.mapleader, '', mapleader.'_', [])
command! ExplainMeta             call s:explain('nmap', '^...<lt>'.g:env.meta_key.'-.>', "<lt>".g:env.meta_key."-_>", ['--ignore=[1-9]'])
command! ExplainUnimpairedToggle call s:explain('nmap yo', '', 'yo_', [])
command! ExplainUnimpairedPrev   call s:explain('nmap [', '', '[_', [])
command! ExplainUnimpairedNext   call s:explain('nmap ]', '', ']_', [])
