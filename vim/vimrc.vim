set nocompatible
set encoding=utf-8
syntax on

let mapleader = ","

let g:dotfiles_dir = expand('<sfile>:p:h:h')

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
runtime settings/mappings.vim
runtime settings/appearance.vim
runtime settings/nvim.vim

runtime settings/plugins/airline.vim

if g:env.nightly
  lua require('mine.lsp')
  lua require('mine.treesitter')
  runtime settings/completion.vim
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

  autocmd WinNew      * let w:check_help = 1
  autocmd BufWinEnter * if exists('w:check_help') | unlet w:check_help | call s:maximize_if_only_help_window(bufnr()) | endif
augroup END

" Commands
command! Snips UltiSnipsEdit
command! Reverse :g/^/m0
command! E doautocmd <nomodeline> User ResetCustomizations | edit

runtime localvimrc

" --- Junk Drawer "  ------------------------------------------------------------

set noswapfile
set signcolumn=number

let g:colorschemes = ['sonokai', 'edge', 'everforest', 'jellybeans', 'lucius',
      \ 'gruvbox', 'OceanicNext', 'nord', 'tokyonight', 'neon', 'dracula']

function! s:cycle_colors()
  let current = index(g:colorschemes, g:colors_name)
  let next = (current + 1) % len(g:colorschemes)
  execute "colorscheme " . g:colorschemes[next]
  echomsg g:colorschemes[next]
endfunction

map <F7> <Cmd>call <SID>cycle_colors()<CR>

function! s:maximize_if_only_help_window(bufnr)
  for nr in tabpagebuflist()
    if a:bufnr == nr     | continue | endif
    if bufname(nr) == '' | continue | endif

    return
  endfor

  only
endfunction

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

" Put WSL GVim where I want it
function! s:position()
  if     g:env.app == 'gvim' && g:env.wsl | call system('~/.scripts/position-me gvim ' . getpid())
  elseif g:env.app == 'neovide'           | call system('~/.scripts/position-me neovide')
  endif

  augroup initial_position | autocmd! | augroup END
endfunction

augroup initial_position
  autocmd BufEnter * call s:position()
augroup END

command! Hfl help function-list

augroup vimrc_junk
  autocmd!
augroup END
