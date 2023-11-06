if g:env.app == 'neovide'
  let g:neovide_cursor_animation_length=0.04
  let g:neovide_scroll_animation_length=0.04
endif

if g:env.app == 'nvim-gtk'
  call rpcnotify(1, 'Gui', 'Option', 'Tabline', 0)
  call rpcnotify(1, 'Gui', 'Option', 'Popupmenu', 0)
endif
