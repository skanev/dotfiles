if g:env.app == 'neovide'
  let g:neovide_cursor_animation_length=0.04
  let g:neovide_refresh_rate=120

  if g:env.os == 'mac'
    let g:neovide_input_use_logo = 1
  endif
endif

if g:env.app == 'nvim-gtk'
  call rpcnotify(1, 'Gui', 'Option', 'Tabline', 0)
  call rpcnotify(1, 'Gui', 'Option', 'Popupmenu', 0)
endif
