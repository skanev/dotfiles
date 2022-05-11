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

let s:vim_lua_prefix = g:dotfiles_dir . '/vim/lua'
let s:lua_in_dotfiles = s#starts_with(expand('%:p'), g:dotfiles_dir)
let s:lua_in_mine = s#starts_with(expand('%:p'), s:vim_lua_prefix)

if s:lua_in_dotfiles && !s:lua_in_mine
  " Runs the current file with luado
  "
  " If the cursor is currently within a function defined in _G._samples, it
  " will also call that function after it loads the file. This is useful to
  " run a particular example fairly easily, instead of having to do extra
  " steps.
  function! s:luado_current_file_with_samples() abort
    luafile %

    let [line, col] = searchpairpos('^function _G\._samples\.\k\+()$', '', '^end\zs$', 'bcn')
    if line != 0 && col != 0
      exec "lua " . matchstr(getline(line), '^function \zs.*()\ze$')
    endif
  endfunction

  map <buffer> Q <Cmd>call <SID>luado_current_file_with_samples()<CR>
endif

if s:lua_in_mine
  let b:lua_module_name = matchstr(expand('%:p'), '^\V' . s:vim_lua_prefix . '/\m\zs.*\ze\.lua$')->substitute('/', '.', 'g')

  function! s:unload()
    exec printf("lua package.loaded['%s'] = nil", b:lua_module_name)
  endfunction

  function! s:full_reload()
    call s:unload()
    call luaeval(printf("require('%s')", b:lua_module_name))
  endfunction

  ":: Mine: Unload current package from vim
  command! -buffer MineLuaUnload call s:unload()

  map <buffer> Q <Cmd>call <SID>full_reload()<CR>
endif
