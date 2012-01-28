syntax on

" Pathogen
filetype off
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()
filetype plugin on

let Tlist_Ctags_Cmd='/opt/local/bin/ctags'
runtime bundle/skanev/early/mapmeta.vim

let Tlist_Show_One_File=1

" This has to be in .vimrc, since NERDTree is... far-sighted
let NERDTreeHijackNetrw=0

map <S-F3> :Explore<CR>

map <C-Left> :bn<CR>
map <C-Right> :bp<CR>

map <D-/> <Plug>NERDCommenterToggle<CR>
autocmd BufnewFile,BufRead *.rb setlocal complete-=i

map <F7> :NERDTreeFind<CR>
map <F8> :%s/<C-r><C-w>//gc<Left><Left><Left>

imap jj <ESC>
imap jk <ESC>
map <Leader>f :sp<CR><Tab>[f

command! CloseHiddenBuffers call s:CloseHiddenBuffers()
function! s:CloseHiddenBuffers()
  let open_buffers = []

  for i in range(tabpagenr('$'))
    call extend(open_buffers, tabpagebuflist(i + 1))
  endfor

  for num in range(1, bufnr("$") + 1)
    if buflisted(num) && index(open_buffers, num) == -1
      exec "bdelete ".num
    endif
  endfor
endfunction
