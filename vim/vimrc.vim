syntax on
set nocompatible

set updatetime=100
set ttyfast

let mapleader = ","

let g:dotfiles_dir = expand('<sfile>:p:h:h')

if has('nvim')
  set runtimepath^=~/.vim runtimepath+=~/.vim/after
end

" My 'early' stuff
runtime early/env.vim
runtime early/term.vim
runtime early/mapmeta.vim
runtime early/sonokai_tweaks.vim

" Pathogen and Vundle
filetype off
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()

" Bundles
call plug#begin('~/.vim/plugged')
runtime settings/plugins.vim
call plug#end()

filetype plugin indent on

runtime settings/options.vim
runtime settings/mappings.vim

autocmd BufEnter *.{js,jsx,ts,tsx} :syntax sync fromstart
autocmd BufLeave *.{js,jsx,ts,tsx} :syntax sync clear

function! PromoteToLet()
  s/\v(\w+)\s+\=\s+(.*)$/let(:\1) { \2 }/
  normal ==
endfunction

command! PromoteToLet :call PromoteToLet()
map <Leader>l :PromoteToLet<CR>

command! Reverse :g/^/m0

function! ExtractVariable()
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

xnoremap <Leader>e <ESC>:call ExtractVariable()<CR>

augroup skanev
  autocmd!
  autocmd InsertEnter * :silent set timeoutlen=200
  autocmd InsertLeave * :silent set timeoutlen=1000
augroup END

set keymap=bulgarian-skanev
set iminsert=0
set imsearch=-1

let NERDTreeIgnore=['node_modules$']

command! Snips UltiSnipsEdit

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

command! Playground :call CreatePlayground()

function! MapQToRerun()
  map <buffer> Q :w<CR>:!tmux send-keys C-e C-u C-l C-p C-m<CR><CR>
endfunction
command! MapQToRerun :call MapQToRerun()

runtime localvimrc
