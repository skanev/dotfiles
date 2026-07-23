if exists('b:did_myftplugin') | finish | endif
let b:did_myftplugin = 1

setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab
onoremap <buffer> i$ :<c-u>normal! T$vt$<CR>
map <buffer> Q :!open -a 'Markoff' %<CR><CR>
setlocal spell
setlocal spelllang=en
setlocal textwidth=80

command! -buffer MarkdownToc :!markdown-toc -i %

if has('nvim')
  highlight default MarkdownPopupBackdrop guibg=#000000 ctermbg=0

  let s:motion_swaps = {
        \ 'j': 'gj', 'k': 'gk', 'gj': 'j', 'gk': 'k',
        \ '0': 'g0', '$': 'g$', 'g0': '0', 'g$': '$',
        \ '<Down>': 'g<Down>', '<Up>': 'g<Up>',
        \ }

  function! s:PopupOpen() abort
    let buf = bufnr('%')

    let backdrop_buf = nvim_create_buf(v:false, v:true)
    let backdrop = nvim_open_win(backdrop_buf, v:false, {
          \ 'relative': 'editor',
          \ 'width': &columns,
          \ 'height': &lines,
          \ 'col': 0,
          \ 'row': 0,
          \ 'style': 'minimal',
          \ 'focusable': v:false,
          \ 'zindex': 40,
          \ })
    call setbufvar(backdrop_buf, '&bufhidden', 'wipe')
    call setwinvar(backdrop, '&winhighlight', 'Normal:MarkdownPopupBackdrop')
    call setwinvar(backdrop, '&winblend', 60)

    let width = min([120, &columns - 4])
    let height = &lines - 6
    call nvim_open_win(buf, v:true, {
          \ 'relative': 'editor',
          \ 'width': width,
          \ 'height': height,
          \ 'col': (&columns - width) / 2,
          \ 'row': 2,
          \ 'border': exists('g:neovide') ? 'solid' : 'rounded',
          \ 'title': ' ' . expand('%:t') . ' ',
          \ 'title_pos': 'center',
          \ })
    let w:markdown_popup = 1
    setlocal wrap linebreak
    setlocal textwidth=0
    setlocal nonumber norelativenumber signcolumn=no
    setlocal scrolloff=2

    for [lhs, rhs] in items(s:motion_swaps)
      execute 'noremap <buffer> ' . lhs . ' ' . rhs
    endfor
    inoremap <buffer> <Down> <C-o>gj
    inoremap <buffer> <Up> <C-o>gk
    nnoremap <buffer> <Tab> <Nop>

    if exists(':RenderMarkdown') && get(b:, 'popup_render', 1)
      silent! RenderMarkdown buf_enable
    endif

    execute printf('autocmd WinClosed %d ++once call %sPopupCleanup(%d, %d)',
          \ win_getid(), expand('<SID>'), buf, backdrop)
  endfunction

  function! s:PopupCleanup(buf, backdrop) abort
    if nvim_win_is_valid(a:backdrop)
      call nvim_win_close(a:backdrop, v:true)
    endif
    call setbufvar(a:buf, '&textwidth', 80)
    for lhs in keys(s:motion_swaps)
      silent! call nvim_buf_del_keymap(a:buf, '', lhs)
    endfor
    silent! call nvim_buf_del_keymap(a:buf, 'i', '<Down>')
    silent! call nvim_buf_del_keymap(a:buf, 'i', '<Up>')
    silent! call nvim_buf_del_keymap(a:buf, 'n', '<Tab>')
    if exists(':RenderMarkdown')
      silent! RenderMarkdown buf_disable
    endif
  endfunction

  function! s:PopupToggle() abort
    if get(w:, 'markdown_popup', 0)
      close
      return
    endif
    call s:PopupOpen()
  endfunction

  function! s:RenderToggle() abort
    if !exists(':RenderMarkdown')
      return
    endif
    let b:popup_render = !get(b:, 'popup_render', 1)
    execute 'RenderMarkdown ' . (b:popup_render ? 'buf_enable' : 'buf_disable')
  endfunction

  command! -buffer MarkdownPopup call <SID>PopupToggle()
  nnoremap <buffer> yop :MarkdownPopup<CR>
  nnoremap <buffer> yom :call <SID>RenderToggle()<CR>
endif
