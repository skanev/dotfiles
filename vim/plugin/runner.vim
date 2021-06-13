let s:modes = {}

let s:modes.test_unit          = {}
let s:modes.test_unit.matcher  = '_test\.rb$'
let s:modes.test_unit.run_file = 'rails test {file}'
let s:modes.test_unit.run_line = 'rails test {file}:{line}'

let s:modes.nosetest          = {}
let s:modes.nosetest.matcher  = '_test\.py$'
let s:modes.nosetest.run_file = 'nosetests --nocapture --rednose {file}'
let s:modes.nosetest.run_line = 'nosetests --nocapture --rednose {file}:{line}'

let s:modes.cucumber          = {}
let s:modes.cucumber.matcher  = '\.feature$'
let s:modes.cucumber.run_file = 'cucumber {file}'
let s:modes.cucumber.run_line = 'cucumber {file}:{line}'

let s:modes.rspec          = {}
let s:modes.rspec.matcher  = '_spec\.rb$'
let s:modes.rspec.run_file = 'rspec --format documentation {file}'
let s:modes.rspec.run_line = 'rspec --format documentation {file}:{line}'

let s:modes.crystal_spec          = {}
let s:modes.crystal_spec.matcher  = '_spec\.cr$'
let s:modes.crystal_spec.run_file = 'crystal spec {file}'
let s:modes.crystal_spec.run_line = 'crystal spec {file}:{line}'

let s:modes.busted          = {}
let s:modes.busted.matcher  = '_spec\.lua$'
let s:modes.busted.run_file = 'busted {file}'
let s:modes.busted.run_line = 'busted {file}{line}'

let s:modes.prove          = {}
let s:modes.prove.matcher  = '\.t$'
let s:modes.prove.run_file = 'prove {file}'
let s:modes.prove.run_line = 'prove {file}:{line}'

function s:configure_buffer()
  for [mode_name, definition] in items(s:modes)
    if match(expand("%"), definition.matcher) != -1
      let b:runner_mode = definition
      break
    endif
  endfor
endfunction

function s:shell(command, ...) abort
  if a:0 > 0
    let command = call('printf', [a:command] + a:000)
  else
    let command = a:command
  endif

  let oldshell = &shell
  set shell=/bin/dash
  let result = system(command)
  let &shell = oldshell

  if v:shell_error != 0
    echohl ErrorMsg
    echomsg "shell failed with: " . v:shell_error
    for line in split(result, "\n")
      echomsg line
    endfor
    echohl None
    throw "runner: shell-out failed"
  endif

  return split(result)
endfunction

" Targets

let s:targets = {}

function! s:targets.tmux(command) abort
  let sessions = s:shell("tmux list-sessions -F '#S'")
  let target_session = fnamemodify(getcwd(), ':t')

  if index(sessions, target_session) == -1
    throw printf("runner: tmux does not have a '%s' session", target_session)
  endif

  let matches = s:shell("tmux list-panes -F '#{pane_current_command};#{pane_mode}' -f '#{==:#P,0}' -t %s:1", target_session)

  if len(matches) == 0     | throw "runner: could not find a pane to run in"
  elseif len(matches) >= 2 | throw "runner: somehow found too many panes to run in: " . join(matches, ', ')
  endif

  let tmux_target = printf("%s:1.0", target_session)
  let parts = split(matches[0], ';')
  let current_command = parts[0]

  if current_command != 'zsh'
    throw printf("runner: target pane in %s not running zsh, but instead: %s", target_session, current_command)
  endif

  if get(parts, 1, '') != ''
    call s:shell('tmux copy-mode -q -t %s:1.0', target_session)
  endif

  call s:shell('tmux select-window -t %s \; send-keys -t %s C-u C-l %s C-m', tmux_target, tmux_target, s:tmux_escape_keys(a:command))
endfunction

function s:tmux_escape_keys(keys)
  return "'" . substitute(a:keys, "'", "'\\\\''", 'g') . "'"
endfunction

" Running

function! s:substitute_command(command)
  let command = a:command

  let command = substitute(command, '{file}', expand('%'), 'g')
  let command = substitute(command, '{line}', line('.'), 'g')

  return command
endfunction

function! s:run_file()
  call s:configure_buffer()
  if !s:ensure_mode() | return | endif

  let command = s:substitute_command(b:runner_mode.run_file)

  call s:run(command)
endfunction

function! s:run_line()
  call s:configure_buffer()
  if !s:ensure_mode() | return | end

  let command = s:substitute_command(b:runner_mode.run_line)

  call s:run(command)
endfunction

function! s:run_file_or_last() abort
  call s:configure_buffer()

  if     exists('b:runner_mode') | call s:run_file()
  elseif exists('s:last_run')    | call s:run(s:last_run)
  else                           | throw "runner: can't run current file and nothing has ran before"
  endif

endfunction

unlet! s:last_run

function! s:run(command)
  let s:last_run = a:command

  call s:targets.tmux(a:command)
endfunction

function! s:run_wrapped(fn)
  " Clear previous error if any
  echo

  try
    call call(a:fn, [])
  catch /^runner: /
    call s:report_error(v:exception)
  endtry
endfunction

" Helper functions

function! s:ensure_mode()
  if !exists('b:runner_mode')
    call s:report_error("No runner found for current file")
    return 0
  endif

  return 1
endfunction

function! s:report_error(msg)
  echohl WarningMsg
  echo a:msg
  echohl None
endfunction

" Commands

command! RunnerRunFile       call s:run_wrapped(function('s:run_file'))
command! RunnerRunFileOrLast call s:run_wrapped(function('s:run_file_or_last'))
command! RunnerRunLine       call s:run_wrapped(function('s:run_line'))

" Mappings

map <Plug>(runner-run-file)         <Cmd>RunnerRunFile<CR>
map <Plug>(runner-run-file-or-last) <Cmd>RunnerRunFileOrLast<CR>
map <Plug>(runner-run-line)         <Cmd>RunnerRunLine<CR>
