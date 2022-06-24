function! MyTabLine()
  let s = ''
  for i in range(tabpagenr('$'))
    " select the highlighting
    if i + 1 == tabpagenr()
      let s ..= '%#TabLineSel#'
    else
      let s ..= '%#TabLine#'
    endif

    " set the tab page number (for mouse clicks)
    let s ..= '%' .. (i + 1) .. 'T'

    " the label is made by MyTabLabel()
    let s ..= ' %{%MyTabLabel(' .. (i + 1) .. ')%} '
  endfor

  " after the last tab fill with TabLineFill and reset tab page nr
  let s ..= '%#TabLineFill#%T'

  " right-align the label to close the current tab page
  if tabpagenr('$') > 1
    let s ..= '%=%#TabLine#%999X X '
  endif

  return s
endfunction


function! MyTabLabel(n)
  let buflist = tabpagebuflist(a:n)
  let winnr = tabpagewinnr(a:n)
  let name = bufname(buflist[winnr - 1])
  let info = getbufinfo(buflist[winnr - 1])

  if name == ''
    let name = '[No Name]'
  elseif s#starts_with(name, $VIMRUNTIME)
    let name = fnamemodify(name, ':t')
  else
    let name = name->fnamemodify(':~:.')->pathshorten()
  endif

  let result = ""

  if buflist->len() > 1
    let result = result . buflist->len() . ' '
  endif

  if info[0]['changed'] == 1
    let result = result . '+ '
  endif

  let result = result . name

  return result
endfunction

set tabline=%!MyTabLine()
set tabline=
