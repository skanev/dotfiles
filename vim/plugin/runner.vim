let s:target_always_vim = 0
let s:modes = {}

" Left here for debugging purposes
"let s:modes.vim          = {}
"let s:modes.vim.matcher  = '\.vim$'
"let s:modes.vim.run_file = 'head -n 10 {file}'
"let s:modes.vim.run_line = 'awk "NR={line}" {file}'

let s:modes.test_unit          = {}
let s:modes.test_unit.matcher  = '_test\.rb$'
let s:modes.test_unit.run_file = 'ruby {file}'
let s:modes.test_unit.run_line = 'm {file}:{line}'

" the above, but for Rails
"let s:modes.test_unit.run_file = 'rails test {file}'
"let s:modes.test_unit.run_line = 'rails test {file}:{line}'

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

let s:modes.plenary          = {}
let s:modes.plenary.matcher  = 'vim/lua/tests/.*_spec\.lua'
let s:modes.plenary.run_file = ':lua require("plenary.test_harness").test_directory(vim.fn.expand("{file}"))'

let s:modes.busted          = {}
let s:modes.busted.matcher  = '_spec\.lua$'
let s:modes.busted.run_file = 'busted {file}'

let s:modes.prove          = {}
let s:modes.prove.matcher  = '\.t$'
let s:modes.prove.run_file = 'prove {file}'
let s:modes.prove.run_line = 'prove {file}:{line}'

let s:modes.go             = {}
let s:modes.go.matcher     = '_test\.go'
let s:modes.go.run_file    = 'go test'

let s:modes.nim            = {}
let s:modes.nim.matcher    = 'test_.*\.nim'
let s:modes.nim.run_file   = 'nim c -r {file}'

let s:modes.vader          = {}
let s:modes.vader.matcher  = '\.vader$'
let s:modes.vader.run_file = ':Vader {file}'

function! s:rust_run_file_command() abort
  let filename = expand('%')

  let match = matchstr(filename, '^tests/\zs.*\ze\.rs$')
  if match != ''
    return printf('cargo test --quiet --test %s', substitute(match, '/', '::', 'g'))
  endif

  let match = matchstr(filename, '^src/\zs.*\ze\.rs$')
  if match != ''
    return printf('cargo test --quiet %s::', substitute(match, '/', '::', 'g'))
  endif

  return 'cargo test'
endfunction

function! s:rust_run_line_command() abort
  let filename = expand('%')
  let test_line = search('#\[test\]\n\(//.*\n\)*\s*\zs\(pub \)\?fn \w\+\ze', 'bnWc')

  if test_line == 0
    throw "runner: cant find an enclosing test"
  endif

  let fn_name = matchstr(getline(test_line), 'fn \zs\w\+\ze')

  let module_name = matchstr(filename, '^tests/\zs.*\ze\.rs$')
  if module_name != ""
    return printf('cargo test --test %s --all %s', substitute(module_name, '/', '::', 'g'), fn_name)
  endif

  let module_name = matchstr(filename, '^src/\zs.*\ze\.rs$')
  if module_name != ""
    return printf('cargo test %s::tests::%s', substitute(module_name, '/', '::', 'g'), fn_name)
  endif


  throw "runner: can't quite figure out how to run this line"
endfunction

let s:modes.rust          = {}
let s:modes.rust.matcher  = '.*\.rs$'
let s:modes.rust.run_file = function('s:rust_run_file_command')
let s:modes.rust.run_line = function('s:rust_run_line_command')

function! s:call_system(command)
  let oldshell = &shell
  set shell=/bin/dash
  let result = system(a:command)
  let &shell = oldshell
  return result
endfunction

function! s:shell(command, ...) abort
  if a:0 > 0
    let command = call('printf', [a:command] + a:000)
  else
    let command = a:command
  endif

  let result = s:call_system(command)

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

function! s:tmux_has_available_session() abort
  let target_session = fnamemodify(getcwd(), ':t')
  let result = s:call_system("tmux has-session -t " . target_session)

  return v:shell_error == 0
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
    setlocal bufhidden=delete
    set nonumber
    wincmd p
  end

  call winrestview(view)
endfunction

function! s:wezterm_has_available_workspace() abort
  return 0
  if !executable('wezterm')
    return 0
  endif

  let target_workspace = fnamemodify(getcwd(), ':t')
  let output = s:call_system('wezterm cli list --format json')
  let panes = json_decode(output)

  for pane in panes
    if pane.workspace == target_workspace
      return 1
    endif
  endfor

  return 0
endfunction

function! s:targets.wezterm(command) abort
  let target_workspace = fnamemodify(getcwd(), ':t')
  let output = s:call_system('wezterm cli list --format json')
  let panes = json_decode(output)

  let pane_id = v:null

  for pane in panes
    if pane.workspace == target_workspace
      let pane_id = pane.pane_id
      break
    endif
  endfor

  if pane_id == v:null
    throw "runner: could not find a pane form workspace: " . target_workspace
  endif

  call s:call_system("wezterm cli send-text --no-paste \"" . a:command . "\n\"")
endfunction

function! s:terminal_on_exit(nbuf, job_id, code, event) abort
  if !nvim_buf_is_valid(a:nbuf) | return | end

  call nvim_buf_set_option(a:nbuf, 'modifiable', v:true)
  call timer_start(20, function('s:terminal_callback_tidy_up', [a:nbuf]))
  if a:code == 0
    call timer_start(3000, function('s:terminal_callback_close', [a:nbuf, win_getid(bufwinnr(a:nbuf))]))
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

function! s:terminal_callback_close(bufnr, win_handle, timer) abort
  if !nvim_win_is_valid(a:win_handle) || a:win_handle == nvim_get_current_win() | return | end

  let view = winsaveview()
  call nvim_win_close(a:win_handle, 0)
  call winrestview(view)
endfunction

" Running

function! s:get_command(command)
  if type(a:command) == v:t_string
    let command = a:command

    let command = substitute(command, '{file}', expand('%'), 'g')
    let command = substitute(command, '{line}', line('.'), 'g')

    return command
  elseif type(a:command) == v:t_func
    return call(a:command, [])
  else
    throw "don't know how to process command " . string(a:command)
  end
endfunction

unlet! s:last_run

function! s:run(command)
  let s:last_run = a:command

  if s#starts_with(a:command, ':')
    execute a:command
  elseif !s:target_always_vim && s:wezterm_has_available_workspace()
    call s:targets.wezterm(a:command)
  elseif !s:target_always_vim && s:tmux_has_available_session()
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
        let command = s:get_command(get(mode, 'run_' . action))
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

" Target configuration
function! s:always_vim()
  let s:target_always_vim = 1
endfunction

function! s:reset_target()
  let s:target_always_vim = 0
endfunction

" Helper functions

function! s:buffer_runner_mode() abort
  if exists('b:runner_mode')
    return b:runner_mode
  endif

  if &buftype != 'nofile' && &buftype != 'terminal'
    let filename = expand('%')
    let matching = s:modes->values()->filter({ _, mode -> match(filename, mode.matcher) != -1 })
    call sort(matching, { a, b -> b.matcher->len() - a.matcher->len() })

    if len(matching) >= 1
      return matching[0]
    endif
  end

  return {}
endfunction

function! s:report_error(msg)
  echohl WarningMsg
  echo a:msg
  echohl None
endfunction

" Local configuration

function! s:set_runner(command)
  let command = a:command

  if a:command[0] == '!'
    let command = a:command[1:]
  elseif stridx(a:command, '{file}') == -1
    let command .= ' {file}'
  endif

  let b:runner_mode = {'run_file': command}
endfunction

augroup Runner
  autocmd!
  autocmd BufHidden * if exists('b:runner_buffer') | bdelete! | endif
augroup END

" Commands

":: Runner: Run file
command! -nargs=0 RunnerRunFile       call s:run_action('file')
":: Runner: Run file or repeat last run
command! -nargs=0 RunnerRunFileOrLast call s:run_action('file', 'last')
":: Runner: Run line
command! -nargs=0 RunnerRunLine       call s:run_action('line')
":: Runner: Always run in Vim
command! -nargs=0 RunnerAlwaysVim     call s:always_vim()
":: Runner: Reset target
command! -nargs=0 RunnerResetTarget   call s:reset_target()

command! -nargs=1 RunWith             call s:set_runner(<q-args>)

" Mappings

map <Plug>(runner-run-file)         <Cmd>RunnerRunFile<CR>
map <Plug>(runner-run-file-or-last) <Cmd>RunnerRunFileOrLast<CR>
map <Plug>(runner-run-line)         <Cmd>RunnerRunLine<CR>
