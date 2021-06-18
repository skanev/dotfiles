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

  let mappings = {}
  let mappings = extend(mappings, s:mappings)
  let mappings = extend(mappings, get(b:, 'insert_leader_mappings', {}))

  if has_key(mappings, input)
    call feedkeys(s:escaped_leader . input)
  else
    echomsg "No mapping for " . s:leader . input
  end

  return "\<Ignore>"
endfunction

function! s:define(cmd, mapping) abort
  let expr = 0
  let mapping = a:mapping
  let options = {}

  let [_, _, pos] = matchstrpos(mapping, '^<buffer>\s\+')
  if pos != -1
    let options.buffer = 1
    let mapping = mapping[pos:]
  endif

  let [_, _, pos] = matchstrpos(mapping, '^<expr>\s\+')
  if pos != -1
    let options.expr = 1
    let mapping = mapping[pos:]
  endif

  let [key, _, pos] = matchstrpos(mapping, '^\S\+\ze\s\+')
  let rhs = mapping[pos:]
  let raw_key = key

  let rhs = substitute(rhs, '^\s*', '', '')

  if key =~ '^<\S\+>$'
    let raw_key = eval('"\' . key . '"')
  endif

  call IMapLeader(a:cmd, options, key, rhs)
endfunction

function! IMapLeader(cmd, options, key, rhs)
  let key    = a:key
  let buffer = get(a:options, 'buffer', 0)
  let expr   = get(a:options, 'expr', 0)

  if key =~ '^<\S\+>$'
    let raw_key = eval('"\' . key . '"')
  else
    let raw_key = key
  endif

  if buffer
    let b:insert_leader_mappings = get(b:, 'insert_leader_mappings', {})
    let b:insert_leader_mappings[raw_key] = a:rhs
  else
    let s:mappings[raw_key] = a:rhs
  end

  let modifiers = ' '
  if expr   | let modifiers .= '<expr> '   | end
  if buffer | let modifiers .= '<buffer> ' | end

  execute a:cmd . modifiers . s:leader . key . ' ' . a:rhs
endfunction

command! -nargs=1 IMapLeader call s:define('imap', <q-args>)
command! -nargs=1 INoReMapLeader call s:define('inoremap', <q-args>)

imap <expr> <C-a> <SID>wait()

INoReMapLeader <expr> <C-a> <C-a>
