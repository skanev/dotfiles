" STREAMLINED MAPPINGS ON THE META KEY
" ------------------------------------
"
" The first few lines of this file deal with providing a consistent way of
" defining mappings on the Alt (or Command) key in GVim, MacVim and terminal
" Vim.  The rest implement a sketchy way of supporting Alt mappings in the
" terminal.

function! MapMeta(modes, modifiers, key, command)
  if g:env.app == 'vim'
    let mapping = '<M-'.a:key.'>'
    call s:register_meta_key(a:key)
  elseif g:env.app == 'nvim-qt' && g:env.meta_key == 'D' && has_key(s:downcases, a:key)
    let mapping = toupper(printf('<S-D-%s>', a:key))
  elseif g:env.app == 'vimr' &&  has_key(s:downcases, a:key)
    let mapping = printf('<S-D-%s>', s:downcases[a:key])
  elseif g:env.app == 'neovide' &&  has_key(s:downcases, a:key)
    let mapping = printf('<S-D-%s>', s:downcases[a:key])
  else
    let mapping = printf('<%s-%s>', g:env.meta_key, a:key)
  endif

  let parts = [a:modifiers, a:key, a:command]
  call filter(parts, "v:val != ''")

  if a:modes == ''
    let modes = ['']
  else
    let modes = split(a:modes, '\zs')
  endif

  for mode in modes
    exec mode . "map " . a:modifiers . " " . mapping .  " " . a:command
  endfor
endfunction

command! -nargs=1 MapMeta  call <SID>map_meta_command(<f-args>)
command! -nargs=1 NMapMeta call <SID>map_meta_command('-n ' . <f-args>)
command! -nargs=1 VMapMeta call <SID>map_meta_command('-v ' . <f-args>)
command! -nargs=1 IMapMeta call <SID>map_meta_command('-i ' . <f-args>)
command! -nargs=1 XMapMeta call <SID>map_meta_command('-x ' . <f-args>)

function! s:map_meta_command(string) abort
  let command = a:string
  let [modes, from, to] = matchstrpos(command, '^\s*-\zs\a\+')

  if to != -1
    let command = substitute(command[to:], '^\s*', '', '')
  endif

  let [modifiers, from, to] = matchstrpos(command, '^\s*\(<\a\+>\s*\)\+')

  if to != -1
    let command   = substitute(command[to:], '^\s*', '', '')
    let modifiers = substitute(modifiers, '\s*$', '', '')
  endif

  try
    let [_, key, command; _] = matchlist(command, '^\s*\(\S\+\)\s\+\(.*\)$')
  catch
    echomsg command . "|||" . a:string
  endtry

  call MapMeta(modes, modifiers, key, command)
endfunction

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
