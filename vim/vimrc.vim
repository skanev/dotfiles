set nocompatible
set encoding=utf-8
syntax on

let mapleader = ","

" Find the correct paths on windows
if exists('$HOMEDRIVE')
  set runtimepath+=~/.vim
  let g:dotfiles_dir = expand('~/code/personal/dotfiles')
else
  let g:dotfiles_dir = expand('<sfile>:p:h:h')
endif

" My 'early' stuff
runtime early/env.vim
runtime early/term.vim
runtime early/insert_leader.vim
runtime early/tweaks.vim
runtime early/mapmeta.vim
runtime early/sonokai_tweaks.vim

" Plug
let s:plug_file = g:dotfiles_dir . '/vim/autoload/plug.vim'
if empty(glob(s:plug_file))
  silent execute '!curl -fLo ' . s:plug_file . ' --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
unlet s:plug_file

call plug#begin(g:dotfiles_dir . '/vim/bundles')
runtime settings/plugins.vim
call plug#end()

packadd! matchit

" Settings
runtime settings/options.vim
runtime settings/commands.vim
runtime settings/mappings.vim
runtime settings/appearance.vim
runtime settings/nvim.vim

if g:env.nvim
  lua require('mine.global')
  lua require('mine.completion')
  lua require('mine.lsp')
  lua require('mine.treesitter')
  lua require('mine.telescope')
  lua require('mine.palette')
  lua require('mine.mire')
  lua require('mine.gitsigns')
  lua require('mine.lualine')
  lua require('mine.snippets')
  lua require('mine.tree')
  lua require('mine.explore_keys')
  lua require('mine.unsaved')
  lua require('mine.send_text')
  lua require('mine.aerial')
  lua require('mine.terminal')
  runtime settings/completion.vim
else
  runtime settings/plugins/airline.vim
end

augroup vimStartup
  autocmd!
  autocmd BufReadPost * if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit' | execute "normal! g`\"" | endif
augroup END

augroup mine
  autocmd!
  autocmd BufEnter *.{js,jsx,ts,tsx} :syntax sync fromstart
  autocmd BufLeave *.{js,jsx,ts,tsx} :syntax sync clear

  autocmd InsertEnter * :silent set timeoutlen=200
  autocmd InsertLeave * :silent set timeoutlen=1000

  autocmd WinNew               * let w:check_help = 1
  autocmd FileType,BufWinEnter * if exists('w:check_help') | unlet w:check_help | call s:maximize_if_only_help_window(bufnr()) | endif
augroup END

" Commands
command! Reverse :g/^/m0
command! MineLog call s#terminal(printf("tail -f %s/mine.nvim.log", stdpath('data')), {'mode': 'side'})
command! E doautocmd <nomodeline> User ResetCustomizations | edit

runtime localvimrc

" --- Junk Drawer "  ------------------------------------------------------------

set noswapfile
set signcolumn=number

let g:colorschemes = ['sonokai', 'gruvbox', 'dracula', 'edge', 'everforest', 'jellybeans',
      \ 'lucius', 'OceanicNext', 'nord', 'tokyonight', 'neon']

function! s:announce_colorscheme(name, ...)
  echomsg a:name
endfunction

function! s:cycle_colors()
  let current = index(g:colorschemes, g:colors_name)
  let next = (current + 1) % len(g:colorschemes)
  execute "colorscheme " . g:colorschemes[next]
  call timer_start(0, function('s:announce_colorscheme', [g:colorschemes[next]]))
endfunction

map <F7> <Cmd>call <SID>cycle_colors()<CR>
map <S-F7> <Cmd>execute "colorscheme " . g:colorschemes[0]<CR>

function! s:maximize_if_only_help_window(bufnr)
  if win_gettype() == 'command' || win_gettype() == 'quickfix' | return | endif
  if getbufvar(a:bufnr, '&buftype') != 'help' | return | endif

  for nr in tabpagebuflist()
    if a:bufnr == nr     | continue | endif
    if bufname(nr) == '' | continue | endif

    return
  endfor

  only
endfunction

function! s:use_treesitter_folding()
  set foldmethod=expr
  set foldexpr=nvim_treesitter#foldexpr()
endfunction

":: Fold: Use treesitter folding in this buffer
command! UseTSFolding call <SID>use_treesitter_folding()

command! Playground :call CreatePlayground()

function! CreatePlayground()
  edit ~/Desktop/playground.rb
  map <buffer> Q :w!<CR>:!ruby % 2>&1 \| perl -pe 's/\e\[?.*?[\@-~]//g'<CR>

  if line('$') == 1 && getline('.') == ''
    let template =<< trim END
      class Solution
        def solve()
        end
      end

      def check(*args, expected)
        actual = Solution.new.solve(*args)
        if expected != actual
          puts "solve(#{args.map(&:inspect) * ', '}) = #{actual.inspect}, but expected #{expected.inspect}"
        end
      end

      check
END

    call append(0, template)
    $delete _
  endif
endfunction

function! MapQToRerun()
  map <buffer> Q :w<CR>:!tmux send-keys C-e C-u C-l C-p C-m<CR><CR>
endfunction

command! MapQToRerun :call MapQToRerun()

command! Hfl help function-list

augroup vimrc_junk
  autocmd!
augroup END
