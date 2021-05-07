map <F1> :help skanev.txt<CR>
map <F2> :ToggleBufExplorer<CR>
map <F3> :NERDTreeToggle<CR>
map <S-F3> :NERDTreeFind<CR>
map <F6> :Scratch<CR>
map <F8> :%s/<C-r><C-w>//gc<Left><Left><Left>
map <S-F8> :Ack <C-r><C-w><CR>
map <F9> :noh<CR>
map <F10> :set cursorcolumn!<CR>
imap <F10> <C-o>:set cursorcolumn!<CR>
map <F11> :Files <C-r>=g:dotfiles_dir<CR><CR>
map <S-F11> :Files <C-r>=g:dotfiles_dir<CR>/vim/<CR>
map <F12> :edit <C-r>=g:dotfiles_dir<CR>/vim/vimrc.vim<CR>

map <C-]> <Plug>(fzf_tags)

imap <expr> jk BulgarianJK()

map <Leader>p <Plug>(SynStack)
map <Leader>g <Cmd>copen<CR>
nmap <Leader>j :SplitjoinJoin<CR>
nmap <Leader>s :SplitjoinSplit<CR>

nnoremap <Tab> <C-w><C-w>
nnoremap <S-Tab> <C-w><C-W>
inoremap <S-Tab> <C-v><C-i>
nnoremap <C-p> <C-i>
nnoremap ,, ,
nnoremap <Space> :
nnoremap <expr> Q ''

nmap [c <Plug>(GitGutterPrevHunk)
nmap ]c <Plug>(GitGutterNextHunk)
nmap [g <Cmd>colder<CR>
nmap ]g <Cmd>cnewer<CR>

nmap <silent> yoa <Cmd>ALEToggleBuffer<CR>
nmap <silent> yog <Cmd>call s:ToggleGitGutter()<CR>

nnoremap <C-h> :SidewaysLeft<CR>
nnoremap <C-l> :SidewaysRight<CR>
nnoremap - :Switch<CR>
cnoremap <C-c> <C-^>
inoremap <C-c> <C-^>

map <C-Left> :bnext<CR>
map <C-Right> :bprevious<CR>

map <expr> g= ':Tabularize /\V' . expand('<cWORD>') . '<CR>'

cnoremap <expr> / <SID>cmd_mode_slash()

MapMeta f <Cmd>Files<CR>
MapMeta j <Cmd>Buffers<CR>

MapMeta ] >>
MapMeta [ <<

VMapMeta ] >gv
VMapMeta [ <gv

MapMeta r <Plug>NexusRunTestFile
MapMeta R <Plug>NexusRunTestLine

MapMeta e <Plug>NexusSendBuffer
VMapMeta e <Plug>NexusSendSelection

MapMeta / <Plug>NERDCommenterToggle
VMapMeta / <Plug>NERDCommenterToggle

if g:env.app != 'mvim'
  MapMeta s :write<CR>
  MapMeta w :close<CR>
  MapMeta t :tabnew<CR>
  MapMeta a ggVG
  MapMeta v "+p

  VMapMeta c "+y
  IMapMeta v <C-r>+
end

function s:sid()
  return '<SNR>' . matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$') . '_'
endfun

" When typing %/ it expands to the directory of the current file.

function s:cmd_mode_slash()
  let line = getcmdline()

  if line[len(line) - 1] == '%' && line[len(line) - 2] == ' ' && getcmdtype() == ':'
    return "\<BS>" . expand('%:h') . '/'
  else
    return '/'
  endif
endfunction

if !g:env.tmux
  for n in range(1, 9)
    call MapMeta('n', printf("%s <Cmd>tabnext %s<cR>", n, n), '<silent>')
  endfor
else
  for n in range(1, 9)
    call MapMeta('nivc', string(n) . ' ' . s:sid() . 'switch_tab(' . n .')', '<expr> <silent>')
  endfor

  function! s:switch_tab(index)
    let tabs = tabpagenr('$')

    if tabs == 1 || a:index > tabs || mode() != 'n'
      call system('~/.scripts/tmux/switch-tab -t ' . a:index)
      return ""
    else
      return ":tabnext " . a:index . "\<CR>"
    endif

    return ""
  endfunction
endif

function! s:InstallTouchbarWorkaroundMappings()
  map <Leader>1 <F1>
  map <Leader>2 <F2>
  map <Leader>b <F2>
  map <Leader>3 <F3>
  map <Leader># <S-F3>
  map <Leader>l <F3>
  map <Leader>L <S-F3>
  map <Leader>6 <F6>
  map <Leader>8 <F8>
  map <Leader>* <S-F8>
  map <Leader>9 <F9>
  map <LeadeR>n <F9>
  map <Leader>0 <F10>
  map <Leader>- <F11>
  map <Leader>= <F12>
endfunction

function! s:ToggleGitGutter()
  GitGutterToggle
  let g:airline#extensions#hunks#enabled = 1
  AirlineRefresh
endfunction

command! InstallTouchbarWorkaroundMappings call s:InstallTouchbarWorkaroundMappings()
