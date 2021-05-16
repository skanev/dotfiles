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

augroup vimStartup
  autocmd!
  autocmd BufReadPost * if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit' | execute "normal! g`\"" | endif
augroup END

" Autocommands
autocmd BufEnter *.{js,jsx,ts,tsx} :syntax sync fromstart
autocmd BufLeave *.{js,jsx,ts,tsx} :syntax sync clear

augroup skanev
  autocmd!
  autocmd InsertEnter * :silent set timeoutlen=200
  autocmd InsertLeave * :silent set timeoutlen=1000
augroup END

" Commands
command! Snips UltiSnipsEdit
command! Reverse :g/^/m0

runtime localvimrc

" --- Junk Drawer "  ------------------------------------------------------------

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
