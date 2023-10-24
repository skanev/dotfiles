map <F1> :help skanev.txt<CR>
map <F2> :ToggleBufExplorer<CR>
map <F3> <Cmd>TreeToggle<CR>
map <S-F3> <Cmd>TreeFind<CR>
map <F6> <Cmd>Scratch<CR>
map <F8> :%s/<C-r><C-w>//gc<Left><Left><Left>
map <S-F8> :Ack <C-r><C-w><CR>
map <F9> :noh<CR>
map <F10> :set cursorcolumn!<CR>
imap <F10> <C-o>:set cursorcolumn!<CR>
map <F11> <Cmd>SearchDotfiles<CR>
map <S-F11> <Cmd>SearchVimDotfiles<CR>
map <F12> :edit <C-r>=g:dotfiles_dir<CR>/vim/vimrc.vim<CR>

map <C-]> <Plug>(fzf_tags)

imap <expr> jk BulgarianJK()

map <Leader>p <Plug>(SynStack)
map <Leader>g <Cmd>copen<CR>
nmap <Leader>j :SplitjoinJoin<CR>
nmap <Leader>s :SplitjoinSplit<CR>
map <Leader>?, <Cmd>ExplainLeader<CR>
map <Leader>?m <Cmd>ExplainMeta<CR>
map <Leader>?M <Cmd>ExplainInsertMeta<CR>
map <Leader>?yo <Cmd>ExplainUnimpairedToggle<CR>
map <Leader>?[ <Cmd>ExplainUnimpairedPrev<CR>
map <Leader>?] <Cmd>ExplainUnimpairedNext<CR>

nnoremap <Tab> <C-w><C-w>
nnoremap <S-Tab> <C-w><C-W>
inoremap <S-Tab> <C-v><C-i>
nnoremap <C-p> <C-i>
nnoremap ,, ,
nnoremap <Space> :
vnoremap <Space> :
nnoremap <expr> Q ''

nmap [c <Plug>(GitGutterPrevHunk)
nmap ]c <Plug>(GitGutterNextHunk)
nmap [g <Cmd>colder<CR>
nmap ]g <Cmd>cnewer<CR>

nmap <silent> yoa <Cmd>ALEToggleBuffer<CR>
nmap <silent> yog <Cmd>call <SID>ToggleGitGutter()<CR>

nnoremap <C-h> :SidewaysLeft<CR>
nnoremap <C-l> :SidewaysRight<CR>
nnoremap <C-k> <Cmd>set hlsearch!<CR>
nnoremap - :Switch<CR>
cnoremap <C-c> <C-^>
inoremap <C-c> <C-^>

map <C-Left> :bnext<CR>
map <C-Right> :bprevious<CR>

map <expr> g= ':Tabularize /\V' . expand('<cWORD>') . '<CR>'

cnoremap <expr> / <SID>cmd_mode_slash()

MapMeta f <Cmd>SearchFiles<CR>
MapMeta j <Cmd>SearchBuffers<CR>
MapMeta k <Cmd>TreeToggle<CR>
if g:env.nvim
  MapMeta m <Cmd>lua require('mine').cycle_diagnostics()<CR>
  MapMeta p <Cmd>Palette<CR>
endif

MapMeta ] >>
MapMeta [ <<

VMapMeta ] >gv
VMapMeta [ <gv

MapMeta r <Plug>(runner-run-file-or-last)
MapMeta R <Plug>(runner-run-line)

if g:env.nvim
  NMapMeta e <Plug>(mine-send-text-buffer)
  VMapMeta e <Plug>(mine-send-text-selection)
else
  MapMeta e <Plug>NexusSendBuffer
  VMapMeta e <Plug>NexusSendSelection
endif

MapMeta / <Plug>NERDCommenterToggle
VMapMeta / <Plug>NERDCommenterToggle

MapMeta w :close<CR>
call MapMeta('i', '<silent><script><expr>', 'm', 'copilot#Accept("\<CR>")')

if g:env.app != 'mvim'
  MapMeta s :write<CR>
  MapMeta t :tabnew<CR>
  MapMeta a ggVG
  MapMeta v "+p

  VMapMeta c "+y
  IMapMeta v <C-r>+
end

function s:sid()
  return '<SNR>' . matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$') . '_'
endfun

if g:env.app == 'nvim-qt' || g:env.app == 'neovide'
  call MapMeta('nvic', '', '-', '<Cmd>call '.s:sid()."set_font('delta', -1)<CR>")
  call MapMeta('nvic', '', '=', '<Cmd>call '.s:sid()."set_font('delta', 1)<CR>")
  call MapMeta('nvic', '', '0', '<Cmd>call '.s:sid()."set_font('reset', 0)<CR>")

  function! s:set_font(action, number)
    if a:action == 'reset'
      let &guifont = g:appearance.font
    elseif a:action == 'delta'
      let size = matchstr(&guifont, '\d\+')
      let &guifont = substitute(&guifont, '\d\+', size + a:number, '')
    else
      throw "Unknown action: " . a:action
    end
  endfunction
endif

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
    call MapMeta('n', '<silent>', string(n), printf("<Cmd>tabnext %s<cR>", n))
  endfor
else
  for n in range(1, 9)
    call MapMeta('nivc', '<expr> <silent>', string(n), s:sid() . 'switch_tab(' . n .')')
  endfor

  function! s:switch_tab(index)
    let tabs = tabpagenr('$')

    if tabs == 1 || a:index > tabs || mode() != 'n'
      call system('~/.scripts/tmux/switch-tab --of-tmux ' . a:index)
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
