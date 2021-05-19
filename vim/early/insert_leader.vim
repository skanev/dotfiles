" Treat <C-a> as a leader in insert.
"
" Because I like to have timeout low in insert, I'm occasionally not fast
" enough to hit the sequence <C-a>x where x is something arbitrary. Enter duct
" tape – <C-a> gets mapped to just wait until I press another key and then it
" triggers the mapping.
"
" Also let <C-a><C-a> be the default <C-a> functionality

let s:mappings = {}
let s:leader = "<C-a>"
let s:escaped_leader = "\<C-a>"

function! s:wait() abort
  let input = nr2char(getchar())

  if has_key(s:mappings, input)
    call feedkeys(s:escaped_leader . input)
  else
    echomsg "No mapping for " . s:leader . input
  end

  return "\<Ignore>"
endfunction

function! s:define(cmd, mapping)
  let expr = 0
  let mapping = a:mapping

  let [_, _, pos] = matchstrpos(a:mapping, '^<expr>\s\+')
  if pos != -1
    let expr = 1
    let mapping = mapping[pos:]
  endif

  let [key, _, pos] = matchstrpos(mapping, '^\S\+\ze\s\+')
  let rhs = mapping[pos:]
  let raw_key = key

  let rhs = substitute(rhs, '^\s*', '', '')

  if key =~ '^<\S\+>$'
    let raw_key = eval('"\' . key . '"')
  endif

  call IMapLeader(a:cmd, expr, key, rhs)
endfunction

function! IMapLeader(cmd, expr, key, rhs)
  let key = a:key
  if key =~ '^<\S\+>$'
    let raw_key = eval('"\' . key . '"')
  endif

  let s:mappings[raw_key] = a:rhs

  execute a:cmd . (a:expr ? ' <expr> ' : ' '). s:leader . key . ' ' . a:rhs
endfunction

command! -nargs=1 IMapLeader call s:define('imap', <q-args>)
command! -nargs=1 INoReMapLeader call s:define('inoremap', <q-args>)

imap <expr> <C-a> <SID>wait()

INoReMapLeader <expr> <C-a> <C-a>
