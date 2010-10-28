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
autocmd User Rails silent! Rnavcommand sass public/stylesheets/sass/ -suffix=.sass

" Some Scheme Stuff
" TODO This should be moved out of here
autocmd BufnewFile,BufRead *-test.ss map <buffer> Q :!mzscheme %<CR>

