" STREAMLINED MAPPINGS ON THE META KEY
" ------------------------------------
"
" The first few lines of this file deal with providing a consistent way of
" defining mappings on the Alt (or Command) key in GVim, MacVim and terminal
" Vim.  The rest implement a sketchy way of supporting Alt mappings in the
" terminal.

function! MapMeta(modes, args, options)
  let key = strpart(a:args, 0, 1)
  let commands = strpart(a:args, 2)

  if g:env.app == 'vim'
    let mapping = '<M-'.key.'>'
    call s:register_meta_key(key)
  elseif g:env.app == 'nvim-qt' && g:env.meta_key == 'D'
    if has_key(s:downcases, key)
      let mapping = toupper(printf('<S-D-%s>', key))
    else
      let mapping = printf('<D-%s>', key)
    endif
  else
    let mapping = printf('<%s-%s>', g:env.meta_key, key)
  endif

  for i in range(len(a:modes))
    let mode = a:modes[i]
    exec mode . "map " . a:options . " " . mapping .  " " . commands
  endfor
endfunction

command! -nargs=1 MapMeta  call MapMeta('n', <f-args>, '')
command! -nargs=1 VMapMeta call MapMeta('v', <f-args>, '')
command! -nargs=1 IMapMeta call MapMeta('i', <f-args>, '')
command! -nargs=1 XMapMeta call MapMeta('x', <f-args>, '')

let s:downcases = {}
let s:lower = 'abcdefghijklmnopqrstuvwxyz`1234567890-=[]\;,./'."'"
let s:upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ~!@#$%^&*()_+{}|:<>?'.'"'

for i in range(0, len(s:lower) - 1)
  let s:downcases[s:upper[i]] = s:lower[i]
endfor

if g:env.app != 'vim'
  finish
end

let s:pending_keys = []
let s:loaded_keys  = {}
let s:loaded       = 0
let s:handle_meta  = 0

function! s:register_meta_key(key)
  if get(s:loaded_keys, a:key)
    return
  endif

  if s:loaded
    call s:set_meta_key(a:key)
  else
    call add(s:pending_keys, a:key)
  endif
endfunction

function! s:set_meta_key(key)
  if !get(s:loaded_keys, a:key)
    silent! execute printf("silent set <M-%s>=%s", a:key, a:key)
    let s:loaded_keys[a:key] = 1
  endif
endfunction

function! s:on_start()
  for key in s:pending_keys
    call s:set_meta_key(key)
  endfor

  let s:loaded = 1
  let s:pending_keys = []
endfunction

function! s:on_exit()
endfunction

autocmd User     SafeStartup call s:on_start()
autocmd VimLeave *           call s:on_exit()
