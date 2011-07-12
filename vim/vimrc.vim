syntax on

" Pathogen
filetype off
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()
filetype plugin on

let Tlist_Ctags_Cmd='/opt/local/bin/ctags'
let Tlist_Show_One_File=1

" Rails autocommands
autocmd User Rails silent! Rnavcommand specmodel spec/models -glob=**/* -suffix=_spec.rb -default=model()
autocmd User Rails silent! Rnavcommand speccontroller spec/controllers -glob=**/* -suffix=_controller_spec.rb -default=controller()
autocmd User Rails silent! Rnavcommand spechelper spec/helpers -glob=**/* -suffix=_helper_spec.rb -default=controller()
autocmd User Rails silent! Rnavcommand specview spec/views -glob=**/* -suffix=.html.erb_spec.rb -default=controller()
autocmd User Rails silent! Rnavcommand stepdef features/step_definitions -suffix=_steps.rb
autocmd User Rails silent! Rnavcommand feature features/ -suffix=.feature
autocmd User Rails silent! Rnavcommand sass public/stylesheets/sass/ -suffix=.scss

" Some Scheme Stuff
" TODO This should be moved out of here
autocmd BufnewFile,BufRead *-test.ss map <buffer> Q :!mzscheme %<CR>

" This has to be in .vimrc, since NERDTree is... far-sighted
let NERDTreeHijackNetrw=0

map <M-u> vaI
map <S-F3> :Explore<CR>

map <C-Left> :bn<CR>
map <C-Right> :bp<CR>

map <D-/> <Plug>NERDCommenterToggle<CR>
autocmd BufnewFile,BufRead *.rb setlocal complete-=i
map <S-F9> :set list<CR>

map <F5> :A<CR>

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
