if exists('b:did_myftplugin') | finish | endif
let b:did_myftplugin = 1

setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
setlocal foldmethod=syntax nofoldenable
setlocal iskeyword+=!
setlocal iskeyword+=?

autocmd BufnewFile,BufRead *.rb setlocal complete-=i

map <Leader>f :AS<CR><C-w>r
xnoremap <Leader>e <ESC>:call s:ExtractVariable()<CR>
map <Leader>l <Cmd>call <SID>PromoteToLet()<CR>

imap <buffer> <C-l> <Space>=><Space>

map <buffer> [r :A<CR>
map <buffer> ]r :R<CR>

onoremap <buffer> i\| :<c-u>normal! T\|vt\|<CR>
onoremap <buffer> a\| :<c-u>normal! F\|vf\|<CR>

function! s:PromoteToLet()
  s/\v(\w+)\s+\=\s+(.*)$/let(:\1) { \2 }/
  normal ==
endfunction

function! s:ExtractVariable()
  try
    let save_a = @a
    let variable = input('Variable name: ')
    normal! gv"ay
    execute "normal! gvc" . variable
    execute "normal! O" . variable . " = " . @a
  finally
    let @a = save_a
  endtry
endfunction

function! s:rubocop_disable_line()
  let offenses = s#rubocop#current_line_offenses()

  if offenses == []
    echohl ErrorMsg
    echomsg "No offences on this line"
    echohl None
  else
    call setline('.', getline('.') . ' # rubocop:disable ' . join(offenses, ' '))
  endif
endfunction

function! s:rubocop_disable_in_project()
  let offenses = s#rubocop#current_line_offenses()

  if offenses == []
    echohl ErrorMsg | echomsg "No offences on this line" | echohl None
  elseif !filereadable('.rubocop.yml')
    echohl ErrorMsg | echomsg "No .rubocop.yml in current directory" | echohl None
  else
    let bufid = bufnr('.rubocop.yml')
    if bufid != -1 && tabpagebuflist()->index(bufid) != -1
      execute bufid->bufwinnr() "wincmd w"
    else
      botright split .rubocop.yml
    end

    for offense in offenses
      call append('$', offense . ": {Enabled: false}")
      normal G
    endfor
  endif
endfunction

function! s:rubocop_show_info()
  let offenses = s#rubocop#current_line_offenses()

  if offenses == []
    echohl ErrorMsg | echomsg "No offences on this line" | echohl None
  else
    for offense in offenses
      let url = s#rubocop#help_url(offense)
      call system("open " . url)
    endfor
  endif
endfunction

":: Rubocop: Disable line
command -buffer -nargs=0 RubocopDisableLine call <SID>rubocop_disable_line()
":: Rubocop: Disable in project
command -buffer -nargs=0 RubocopDisableInProject call <SID>rubocop_disable_in_project()
":: Rubocop: Show offense info
command -buffer -nargs=0 RubocopShowInfo call <SID>rubocop_show_info()
