" Treat <C-a> as a leader in insert.
"
" Because I like to have timeout low in insert, I'm occasionally not fast
" enough to hit the sequence <C-a>x where x is something arbitrary. Enter duct
" tape – <C-a> gets mapped to just wait until I press another key and then it
" triggers the mapping.
"
" Also let <C-a><C-a> be the default <C-a> functionality

function s:wait() abort
  let input = nr2char(getchar())
  let cmd = "\<C-a>" . input

  if maparg(cmd, 'i')
    call feedkeys(cmd)
  else
    echo "No mapping for " . cmd
  endif

  return "\<Ignore>"
endfunction

imap     <expr> <C-a>      <SID>wait()
inoremap        <C-a><C-a> <C-a>
