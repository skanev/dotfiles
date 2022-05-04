command! OpenTelescope :e ~/.vim/bundles/telescope.nvim/
command! SearchTelescope lua require('telescope.builtin').find_files(require('telescope.themes').get_ivy({cwd = '~/.vim/bundles/telescope.nvim'}))
