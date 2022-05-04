if exists("b:did_myftplugin") | finish | endif
let b:did_myftplugin = 1

set softtabstop=2 tabstop=2 shiftwidth=2 expandtab
let b:switch_custom_definitions =
    \ [
    \   {
    \     'it(': 'pending(',
    \     'pending(': 'it(',
    \   },
    \ ]

if s#starts_with(expand('%:p'), g:dotfiles_dir)
  map <buffer> Q :luafile %<CR>
endif

let s:vim_lua_prefix = g:dotfiles_dir . '/vim/lua'

if s#starts_with(expand('%:p'), s:vim_lua_prefix)
  let b:lua_module_name = matchstr(expand('%:p'), '^\V' . s:vim_lua_prefix . '/\m\zs.*\ze\.lua$')->substitute('/', '.', 'g')

  function! s:unload()
    exec printf("lua package.loaded['%s'] = nil", b:lua_module_name)
  endfunction

  ":: Mine: Unload current package from vim
  command! -buffer MineLuaUnload call s:unload()
endif
