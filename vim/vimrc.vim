set nocompatible
syntax on

let mapleader = ","

let g:dotfiles_dir = expand('<sfile>:p:h:h')

" My 'early' stuff
runtime early/env.vim
runtime early/term.vim
runtime early/mapmeta.vim
runtime early/sonokai_tweaks.vim

" Plug
let s:plug_file = g:dotfiles_dir . '/vim/autoload/plug.vim'
if empty(glob(s:plug_file))
  silent execute '!curl -fLo ' . s:plug_file . ' --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
unlet s:plug_file

call plug#begin('~/.vim/bundles')
runtime settings/plugins.vim
call plug#end()

" Settings
runtime settings/options.vim
runtime settings/mappings.vim

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
if g:env.profile == 'gvim-wsl'
  function! s:position()
    let window_id = trim(system(printf("xdotool search --onlyvisible --pid %s", getpid())))
    call system(printf("xdotool windowmove %s 1 45", window_id))
    call system(printf("xdotool windowsize %s 1910 2053", window_id))

    augroup initial_position
      autocmd!
    augroup END
  endfunction

  augroup initial_position
    autocmd BufEnter * call s:position()
  augroup end
endif
