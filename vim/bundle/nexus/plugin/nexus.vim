let s:types = {}

let s:types.vim = {}
let s:types.vim.matcher = "\.vim$"
let s:types.vim.file = '"echo " . expand("%")'

let s:types.cucumber = {}
let s:types.cucumber.matcher = '\.feature$'
let s:types.cucumber.file = '"command cucumber " . expand("%") . " --drb"'
let s:types.cucumber.line = '"command cucumber " . expand("%") . ":" . line(".") . " --drb"'

let s:types.rspec = {}
let s:types.rspec.matcher = '_spec\.rb$'
let s:types.rspec.file = '"command rspec --format nested " . expand("%") . " --drb"'
let s:types.rspec.line = '"command rspec --format nested " . expand("%") . " --line " . line(".") . " --drb"'

function! s:tmux(command)
  let project = fnamemodify(getcwd(), ':t')
  let escaped = shellescape(a:command)
  let tmuxCall = "tmux send-keys -t " . project . ":nexus C-l C-u " . escaped . " C-m"
  call system(tmuxCall)
endfunction

function! s:run(command)
  let commands = {}

  for [type, definition] in items(s:types)
    if match(expand("%"), definition.matcher) != -1
      let commands = definition
      break
    endif
  endfor

  if !has_key(commands, a:command)
    echohl ErrorMsg | echo "Nexus: undefined command " . a:command | echohl None
    return
  end

  call s:tmux(eval(commands[a:command]))
endfunction

map <expr> <Plug>NexusRunFile <SID>run('file')
map <expr> <Plug>NexusRunLine <SID>run('line')

map <D-r> <Plug>NexusRunFile
map <D-R> <Plug>NexusRunLine
