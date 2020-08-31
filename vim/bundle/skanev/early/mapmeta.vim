" STREAMLINED MAPPINGS ON THE META KEY
" ------------------------------------
"
" The first few lines of this file deal with providing a consistent way of
" defining mappings on the Alt (or Command) key in GVim, MacVim and terminal
" Vim.  The rest implement a sketchy way of supporting Alt mappings in the
" terminal with a little help from tmux.

let s:hijackPrefixVim = '<C-S-F12>'
let s:hijackPrefixTmux = substitute(system('tmux show -vg @meta-prefix'), '\n$', '', '')

function! MapMeta(modes, args, options)
  let key = strpart(a:args, 0, 1)
  let commands = strpart(a:args, 2)
  if has('gui_macvim') && has("gui_running")
    let mapping = '<D-'.key.'>'
  elseif has('gui_running')
    let mapping = '<M-'.key.'>'
  else
    call s:HijackKey(key)

    let mapping = s:hijackPrefixVim.key
  endif

  for i in range(len(a:modes))
    let mode = a:modes[i]
    exec mode . "map " . a:options . mapping .  " " . commands
  endfor

endfunction

command! -nargs=1 MapMeta call MapMeta('n', <f-args>, '')
command! -nargs=1 VMapMeta call MapMeta('v', <f-args>, '')
command! -nargs=1 IMapMeta call MapMeta('i', <f-args>, '')

" SUPPORT FOR TERMINAL ALT MAPPINGS
" ---------------------------------
"
" Pressing <A-j> in the terminal sends <Esc>j.  This would have been the end
" of it, but Vim does not take mapping the <Esc> key in normal mode lightly.
" In my setup, if there is a mapping on <Esc> (even if <Esc> is a prefix, like
" in <Esc>j), starting Vim behaves weirdly.  An alternative would be to have
" the terminal send normal characters with the higher bit set (like Alt) does,
" but this leads to a myriad of problems in other applications.
"
" Thus, a creative solution is called for.
"
" Tmux will intercept Alt mappings (like M-j).  It will then take a look at
" the window name.  It will then send a normal escape sequence (<Esc>j) unless
" Vim is running in the current window, in which case it will send an
" alternative sequence (like <F48>j).  Vim will have the required mapping on
" this sequence, instead of the original one.  MapMeta will register a M-
" mapping in tmux that does this forwarding whenever a key is bound in Vim.
"
" Here are specifics:
"
" * Calling system() is extremely slow, so all the tmux communication is
"   batched in two calls – one initial to figure out which keys are bound (and
"   ensure a proper window name) and another to bind all the keys, missing in
"   tmux.
" * If a M- key is bound in tmux, Vim doesn't override it.
" * We need to make sure that the window is properly named – for example,
"   running Vim keeps the window name to 'mutt', which disables the mappings.

let s:loaded        = 0
let s:hijacked_keys  = []
let s:command_queue = []

function! s:HijackCommand(key)
  return "bind-key -n 'M-" . a:key . "'" .
        \" if-shell \"[ '#W' == 'vim' ]\"".
        \" 'send-keys " . s:hijackPrefixTmux . a:key . "'" .
        \" 'send-keys " . a:key . "'"
endfunction

function! s:HijackKey(key)
  if index(s:hijacked_keys, a:key) != -1
    return
  endif

  let cmd = s:HijackCommand(a:key)

  if s:loaded == 1
    call s:TmuxSend([cmd])
  else
    call add(s:command_queue, cmd)
  endif
endfunction

function! s:TmuxSend(cmds)
  if len(a:cmds) == 0
    return
  endif

  echo system('tmux ' . join(a:cmds, ' \; '))
endfunction

function! s:TmuxInspect()
  let output = system('tmux rename-window vim \; list-keys')

  let pos = 0
  while 1
    let pos = match(output, 'bind-key\s\+-T root\s\+M-\(.\)', pos + 1)

    if pos == -1
      break
    endif

    let key = matchlist(output, 'M-\(.\)', pos)[1]
    call add(s:hijacked_keys, key)
  endwhile
endfunction

function! s:OnVimEnter()
  call s:TmuxSend(s:command_queue)

  let s:command_queue = []
  let s:loaded        = 1
endfunction

function! s:OnVimLeave()
  call s:TmuxSend(['setw automatic-rename on'])
endfunction

if !has('gui_running') && $TMUX != ""
  call s:TmuxInspect()

  augroup mapmeta
    autocmd!
    autocmd VimEnter * call s:OnVimEnter()
    autocmd VimLeave * call s:OnVimLeave()
  augroup END
end
