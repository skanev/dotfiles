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

function! s:shell(command, ...) abort
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

function! s:tmux_has_available_session()
  let sessions = s:shell("tmux list-sessions -F '#S'")
  let target_session = fnamemodify(getcwd(), ':t')

  return index(sessions, target_session) != -1
endfunction

function! s:tmux_escape_keys(keys)
  return "'" . substitute(a:keys, "'", "'\\\\''", 'g') . "'"
endfunction

function! s:targets.terminal(command) abort
  if !has('nvim') | throw 'no non-nvim support yet (can you imagine?)' | end

  let view = winsaveview()

  if s:terminal_current_runner_window().winnr != -1
    call s:terminal_close_runner_window()
  else
    let height = float2nr((&lines - 3) * 0.3)
    execute "botright " . height . "new"
    call termopen(a:command, {'on_exit': function('s:terminal_on_exit', [bufnr()])})
    let b:runner_buffer = 1
    set nonumber
    wincmd p
  end

  call winrestview(view)
endfunction

function! s:terminal_on_exit(nbuf, job_id, code, event) abort
  call nvim_buf_set_option(a:nbuf, 'modifiable', v:true)
  call timer_start(20, function('s:terminal_callback_tidy_up', [a:nbuf]))
  if a:code == 0
    call timer_start(2000, function('s:terminal_callback_close', [win_getid(bufwinnr(a:nbuf))]))
  end
endfunction

function! s:terminal_current_runner_window()
  for nwin in gettabinfo(tabpagenr())[0].windows
    let nbuf = winbufnr(nwin)

    if getbufvar(nbuf, 'runner_buffer', 0)
      return {'bufnr': nbuf, 'winnr': bufwinnr(nbuf)}
    endif
  endfor

  return {'bufnr': -1, 'winnr': -1}
endfunction

function! s:terminal_close_runner_window()
  let window = s:terminal_current_runner_window()

  if window.winnr != -1 && window.winnr != winnr()
    execute window.winnr . "wincmd q"
  endif
endfunction

function! s:terminal_callback_tidy_up(nbuf, timer) abort
  let lines = nvim_buf_get_lines(a:nbuf, 0, -1, 0)

  let i = len(lines)
  while i > 0
    if lines[i - 1] == '' || lines[i - 1] =~ '^\[Process exited \d\+\]$'
      let i -= 1
    else
      break
    endif
  endwhile

  call nvim_buf_set_lines(a:nbuf, i, -1, 0, [])
endfunction

function! s:terminal_callback_close(win_handle, timer) abort
  if !nvim_win_is_valid(a:win_handle) || a:win_handle == nvim_get_current_win() | return | end

  let view = winsaveview()
  call nvim_win_close(a:win_handle, 0)
  call winrestview(view)
endfunction

" Running

function! s:substitute_command(command)
  let command = a:command

  let command = substitute(command, '{file}', expand('%'), 'g')
  let command = substitute(command, '{line}', line('.'), 'g')

  return command
endfunction

unlet! s:last_run

function! s:run(command)
  let s:last_run = a:command

  if s:tmux_has_available_session()
    call s:targets.tmux(a:command)
  else
    call s:targets.terminal(a:command)
  end
endfunction

function! s:run_action(...) abort
  try
    let mode = s:buffer_runner_mode()

    let command = ''

    for action in a:000
      if action == 'last'
        if !exists('s:last_run')
          throw "runner: can't run current file and nothing has ran before"
        endif

        let command = s:last_run
      elseif has_key(mode, 'command')
        let command = call(mode.command, [action])
      elseif has_key(mode, 'run_' . action)
        let command = s:substitute_command(get(mode, 'run_' . action))
      endif

      if command != '' | break | end
    endfor

    if command == ''
      throw "runner: don't know how to run this file"
    endif

    call s:run(command)
  catch /^runner: /
    call s:report_error(v:exception)
  endtry
endfunction

" Helper functions

function! s:buffer_runner_mode() abort
  if exists('b:runner_mode')
    return b:runner_mode
  endif

  for [mode_name, definition] in items(s:modes)
    if match(expand("%"), definition.matcher) != -1
      return definition
    endif
  endfor

  return {}
endfunction

function! s:configure_buffer()
endfunction

function! s:report_error(msg)
  echohl WarningMsg
  echo a:msg
  echohl None
endfunction

" Commands

command! RunnerRunFile       call s:run_action('file')
command! RunnerRunFileOrLast call s:run_action('file', 'last')
command! RunnerRunLine       call s:run_action('line')

" Mappings

map <Plug>(runner-run-file)         <Cmd>RunnerRunFile<CR>
map <Plug>(runner-run-file-or-last) <Cmd>RunnerRunFileOrLast<CR>
map <Plug>(runner-run-line)         <Cmd>RunnerRunLine<CR>
