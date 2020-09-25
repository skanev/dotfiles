" Initialize g:nexusVim {{{1
if !exists('g:nexusVim')
  if has("gui_macvim") && has("gui_running")
    let g:nexusVim = 'mvim'
  elseif has("gui_running")
    let g:nexusVim = 'gvim'
  else
    let g:nexusVim = 'vim'
  end
endif

" Modes and targets {{{1
let s:runners_path = expand('<sfile>:h:h') . '/runners'

let s:modes = {}

let s:modes.test_unit = {}
let s:modes.test_unit.matcher = '_test\.rb$'
let s:modes.test_unit.run_test = '"rails test " . expand("%")'
let s:modes.test_unit.run_test_line = '"rails test " . expand("%") . ":" . line(".")'

let s:modes.nosetest = {}
let s:modes.nosetest.matcher = '_test\.py$'
let s:modes.nosetest.run_test = '"nosetests --nocapture --rednose " . expand("%")'
let s:modes.nosetest.run_test_line = '"nosetests --nocapture --rednose " . expand("%") . ":" . line(".")'

let s:modes.cucumber = {}
let s:modes.cucumber.matcher = '\.feature$'
let s:modes.cucumber.run_test = '"command cucumber " . expand("%") . " --drb"'
let s:modes.cucumber.run_test_line = '"command cucumber " . expand("%") . ":" . line(".") . " --drb"'

let s:modes.rspec = {}
let s:modes.rspec.matcher = '_spec\.rb$'
let s:modes.rspec.run_test = '"rspec --format documentation " . expand("%")'
let s:modes.rspec.run_test_line = '"rspec --format documentation " . expand("%") . ":" . line(".")'
let s:modes.rspec.errorformat = "%f:%l:%m"
let s:modes.rspec.test_runner = 'rspec.rb'

let s:modes.perl = {}
let s:modes.perl.matcher = '\.t$'
let s:modes.perl.run_test = '"prove " . expand("%")'
let s:modes.perl.run_test_line = '"prove " . expand("%")'

" Nexus utility functions {{{1
function! s:currentSessionName()
  return fnamemodify(getcwd(), ':t')
endfunction

function! s:tmux(command)
  if s:notRunning() | return s:errorNotRunning() | endif

  let session = s:currentSessionName()
  let escaped = shellescape(a:command)
  let tmuxCall = "tmux send-keys -t " . session . ":1 C-l C-u " . escaped . " C-m"
  call system(tmuxCall)
endfunction

function! s:run(target)
  let commands = {}

  for [mode, definition] in items(s:modes)
    if match(expand("%"), definition.matcher) != -1
      let commands = definition
      break
    endif
  endfor

  if has_key(commands, a:target)
    let command = eval(commands[a:target])
    let g:nexusLastTest = command
    call s:tmux(command)
  elseif exists("g:nexusLastTest")
    call s:tmux(g:nexusLastTest)
  else
    echohl ErrorMsg | echo "Nexus: cannot run current file (" . a:target . ")"| echohl None
    return
  end
endfunction

function! s:sendKeys(text)
  if s:notRunning() | return s:errorNotRunning() | endif

  let session = s:currentSessionName()
  let lines = split(a:text, "\n")

  for line in lines
    let keys = shellescape(line)
    let keys = substitute(keys, ';', "' '" . '\\;' . "' '", "g")
    call system("tmux send-keys -t " . session . " " . keys . " C-m")
  endfor
endfunction

function! s:sessionRunning()
  let existingSessions = split(system("tmux list-sessions | cut -f 1 -d :"))
  return index(existingSessions, s:currentSessionName()) >= 0
endfunction

function! s:notRunning()
  return !s:sessionRunning()
endfunction

function! s:errorNotRunning()
  if s:notRunning()
    echohl WarningMsg | echo 'Cannot interact with tmux - session is not running' | echohl None
  end
endfunction

function! s:runner(mode)
  if !has_key(s:modes, a:mode)
    echoerr "Undefined mode: " . a:mode | return
  elseif !has_key(s:modes[a:mode], 'test_runner')
    echoerr "The mode '" . a:mode . "' does not have a test runner" | return
  else
    let path = s:runners_path . '/' . s:modes[a:mode].test_runner
    return fnamemodify(path, ':~:.')
  endif
endfunction

" Session management {{{1
function! s:createSession()
  let session = s:currentSessionName()
  let existingSessions = split(system("tmux list-sessions | cut -f 1 -d :"))

  if s:sessionRunning()
    echohl WarningMsg | echo "tmux session already created. Run 'tmux attach -t " . session . "' to join it." | echohl None
    return
  end

  call system('NEXUS_VIM=' . g:nexusVim . ' tmux new-session -d -s ' . session)
  call system('tmux rename-window -t ' . session . ' nexus')
  echohl MoreMsg | echo "tmux session created. Run 'tmux attach -t " . session . "' to join it." | echohl None
endfunction

" Sending text {{{1
function! s:sendSelection()
  call s:sendKeys(s:selectedText())
endfunction

function! s:sendBuffer()
  call s:sendKeys(s:currentBufferContents())
endfunction

" Reading text {{{1
function! s:readPane()
  if s:notRunning() | return s:errorNotRunning() | endif

  let session = s:currentSessionName()
  call system('tmux capture-pane -t ' . session)

  let contents = system('tmux save-buffer - | cat')
  let contents = substitute(contents, '\v[\n ]+$', '', 'g')
  let lines = split(contents, "\n")

  call append(line('.'), lines)
endfunction

" Utility functions {{{1
function! s:selectedText()
  try
    let a_save = @a
    normal! gv"ay
    return @a
  finally
    let @a = a_save
  endtry
endfunction

function! s:currentBufferContents()
  return join(getline(0, '$'), "\n")
endfunction

" Commands {{{1
command! Nexus call s:createSession()
command! NexusSendBuffer call s:sendBuffer()
command! NexusReadPane call s:readPane()

" Mappings {{{1
noremap <expr> <Plug>NexusRunTestFile <SID>run('run_test')
noremap <expr> <Plug>NexusRunTestLine <SID>run('run_test_line')
noremap <expr> <Plug>NexusSendBuffer <SID>sendBuffer()
xnoremap <Plug>NexusSendSelection <ESC>:call <SID>sendSelection()<CR>

" vim:set et ft=vim foldmethod=marker ts=2 sts=2 sw=2
