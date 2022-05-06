if exists('b:did_myftplugin') | finish | endif
let b:did_myftplugin = 1

setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab

if expand('%:t') == '.rubocop.yml'
  function! s:show_rubocop_docs()
    let pattern = '^\w\+/\w\+\ze:'
    let [line, char] = searchpos(pattern, 'bcnW')
    if [line] != [0]
      let cop = matchstr(getline(line), pattern)
      let url = s#rubocop#help_url(cop)
      call system('open ' . url)
    else
      normal! K
    endif
  endfunction

  map <buffer> K <Cmd>call <SID>show_rubocop_docs()<CR>
endif
