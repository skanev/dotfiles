if g:env.app == 'neovide'
  let g:neovide_cursor_animation_length = 0.04
  let g:neovide_scroll_animation_length = 0.07
  let g:neovide_floating_blur_amount_x = 4.0
  let g:neovide_floating_blur_amount_y = 3.0
  let g:neovide_transparency = 0.8
  let g:neovide_frame = 0
  let g:neovide_padding_top = 0
  set linespace=3

  function! s:adjust_background()
    let color = synIDattr(synIDtrans(hlID("Normal")), "bg")
    let g:neovide_background_color = color.'ff'
  endfunction

  augroup neovide
    autocmd!
    autocmd ColorScheme * call s:adjust_background()
  augroup END

  call s:adjust_background()
endif

if g:env.app == 'nvim-gtk'
  call rpcnotify(1, 'Gui', 'Option', 'Tabline', 0)
  call rpcnotify(1, 'Gui', 'Option', 'Popupmenu', 0)
endif
