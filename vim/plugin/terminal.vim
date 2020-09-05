if has('gui_running')
  finish
endif

MapMeta s :w<CR>
MapMeta w :close<CR>
MapMeta t :tabnew<CR>
MapMeta a ggVG
VMapMeta c "*y
VMapMeta x "*d
MapMeta v "*p
IMapMeta v <C-o>:set paste<CR><C-r>*<C-o>:set nopaste<CR>

if $TMUX != ""
  function s:SID()
    return '<SNR>' . matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$') . '_'
  endfun

  let SID = s:SID()

  call MapMeta('nivc', '1 ' . SID . 'SwitchTab(1)', '<expr> <silent>')
  call MapMeta('nivc', '2 ' . SID . 'SwitchTab(2)', '<expr> <silent>')
  call MapMeta('nivc', '3 ' . SID . 'SwitchTab(3)', '<expr> <silent>')
  call MapMeta('nivc', '4 ' . SID . 'SwitchTab(4)', '<expr> <silent>')
  call MapMeta('nivc', '5 ' . SID . 'SwitchTab(5)', '<expr> <silent>')
  call MapMeta('nivc', '6 ' . SID . 'SwitchTab(6)', '<expr> <silent>')
  call MapMeta('nivc', '7 ' . SID . 'SwitchTab(7)', '<expr> <silent>')
  call MapMeta('nivc', '8 ' . SID . 'SwitchTab(8)', '<expr> <silent>')
  call MapMeta('nivc', '9 ' . SID . 'SwitchTab(9)', '<expr> <silent>')

  function! s:SwitchTab(index)
    let tabs = tabpagenr('$')

    if tabs == 1 || a:index > tabs || mode() != 'n'
      call s#system('~/.scripts/tmux/switch-tab -t ' . a:index)
      return ""
    else
      return ":tabnext " . a:index . "\<CR>"
    endif

    return ""
  endfunction
endif
