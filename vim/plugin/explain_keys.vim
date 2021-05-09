function! s:explain(cmd, match, pattern)
  let old_a = @a

  redir! @a
  execute "silent " . a:cmd
  redir END

  let lines = split(@a, "\n")
  let @a = old_a

  call filter(lines, "match(v:val, a:match) != -1")

  let file = tempname()
  call writefile(lines, file)

  call s#popup(printf('~/.scripts/explain-vim-keys %s %s', shellescape(a:pattern), file), {'width': 75})
endfunction

command! ExplainLeader call s:explain('nmap '.mapleader, '', mapleader.'_')
command! ExplainMeta   call s:explain('nmap', '^...<lt>M-.>', "<lt>M-_>", )
